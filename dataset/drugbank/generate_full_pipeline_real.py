import os
import re
import json
import pandas as pd
from pathlib import Path
from difflib import get_close_matches

# =====================================================================
# CONFIG
# =====================================================================
BASE = Path(r"D:\dataset")
CACHE = BASE / "real_data_cache"
OUT = BASE / "drugbank_full_real"
OUT.mkdir(parents=True, exist_ok=True)

DRUGBANK = r"D:\dataset\drugbank\drugbank_clean.csv"

# =====================================================================
# UTILS
# =====================================================================
def sql_escape(text):
    if not text or text is None:
        return "NULL"
    return "'" + str(text).replace("'", "''") + "'"

def normalize(t):
    if not t:
        return ""
    t = t.lower()
    t = re.sub(r"[^a-z0-9 ]+", " ", t)
    t = re.sub(r"\s+", " ", t).strip()
    return t

def pick_keywords(text):
    text = normalize(text)
    tokens = text.split()
    return [w for w in tokens if len(w) > 3]

# =====================================================================
# LOAD CACHE DATA
# =====================================================================
icd10 = json.load(open(CACHE/"icd10.json", encoding="utf-8"))
usda_foods = json.load(open(CACHE/"usda_foods.json", encoding="utf-8"))
usda_nutrients = json.load(open(CACHE/"usda_nutrients.json", encoding="utf-8"))
dailymed_index = json.load(open(CACHE/"dailymed_index.json", encoding="utf-8"))
dailymed_spl = json.load(open(CACHE/"dailymed_spl.json", encoding="utf-8"))

# =====================================================================
# LOAD DRUGBANK
# =====================================================================
df_drug = pd.read_csv(DRUGBANK)

# =====================================================================
# 1) BUILD drug.sql
# =====================================================================
drug_sql = []
drug_map = {}
next_id = 1

for _, row in df_drug.iterrows():
    drugbank_id = row["drugbank-id"]
    name = row["name"]
    description = row["description"] if pd.notna(row["description"]) else None

    drug_map[drugbank_id] = next_id

    drug_sql.append(
        f"INSERT INTO drug (drug_id, name_en, description, source_link, is_active) "
        f"VALUES ({next_id}, {sql_escape(name)}, {sql_escape(description)}, "
        f"{sql_escape(drugbank_id)}, TRUE);"
    )
    next_id += 1

open(OUT/"drug.sql", "w", encoding="utf-8").write("\n".join(drug_sql))

# =====================================================================
# 2) BUILD healthcondition.sql (ICD-10 Full)
# =====================================================================
hc_sql = []
icd_map = {}    # code → condition_id
next_cond = 1

icd_list = []
for item in icd10:
    code = item["code"]
    name = item["desc"]
    icd_map[code] = next_cond
    icd_list.append((next_cond, code, name))
    next_cond += 1

for cid, code, name in icd_list:
    hc_sql.append(
        f"INSERT INTO healthcondition (condition_id, name_en, category) "
        f"VALUES ({cid}, {sql_escape(name)}, {sql_escape(code)});"
    )

open(OUT/"healthcondition.sql", "w", encoding="utf-8").write("\n".join(hc_sql))

# =====================================================================
# 3) drughealthcondition.sql (DailyMed Indications)
# =====================================================================
dhc_sql = []

if not dailymed_spl:
    print("⚠️  WARNING: dailymed_spl.json is EMPTY! Run fetch_data_real.py first.")
    print("   Creating drughealthcondition.sql with 0 records.")
else:
    print(f"Processing {len(dailymed_spl)} SPL records for drug-health conditions...")

# Build index for ICD10 matching
icd_norm = {normalize(item["desc"]): item["code"] for item in icd10}
icd_desc_list = list(icd_norm.keys())

for drugbank_id, drug_id in drug_map.items():
    drug_row = df_drug[df_drug["drugbank-id"] == drugbank_id]
    if drug_row.empty:
        continue
    drug_name = drug_row["name"].iloc[0]
    norm_drug = normalize(drug_name)

    spl_count = 0
    for spl_id, spl in dailymed_spl.items():
        if spl_count >= 200:
            break
        names = [normalize(i) for i in spl.get("data", {}).get("name", [])]
        if any(norm_drug in n for n in names):
            spl_count += 1
            indications = spl["data"].get("indications", [])
            for ind in indications:
                cleaned = normalize(ind)
                tokens = pick_keywords(cleaned)
                matched_codes = set()
                for tk in tokens:
                    fuzzy = get_close_matches(tk, icd_desc_list, n=2, cutoff=0.55)
                    for fz in fuzzy:
                        matched_codes.add(icd_norm[fz])
                for code in matched_codes:
                    cond_id = icd_map[code]
                    if len(dhc_sql) < 200:
                        dhc_sql.append(
                            f"INSERT INTO drughealthcondition (drug_id, condition_id, treatment_notes, is_primary) "
                            f"VALUES ({drug_id}, {cond_id}, {sql_escape(ind)}, TRUE);"
                        )

open(OUT/"drughealthcondition.sql", "w", encoding="utf-8").write("\n".join(dhc_sql))

# =====================================================================
# 4) drugnutrientcontraindication.sql (Smart Matching)
# =====================================================================
if not dailymed_spl:
    print("⚠️  WARNING: dailymed_spl.json is EMPTY! Run fetch_data_real.py first.")
    print("   Creating drugnutrientcontraindication.sql with 0 records.")
else:
    print(f"Processing {len(dailymed_spl)} SPL records for drug-nutrient contraindications...")

NUTRIENT_MAP = {
    "calcium": 24, "calcium carbonate": 24,
    "magnesium": 26,
    "iron": 29, "ferrous": 29, "ferric": 29,
    "zinc": 30,
    "fiber": 5, "dietary fiber": 5,
    "fat": 3, "total lipid": 3, "fatty": 3,
    "protein": 2,
    "vitamin k": 14, "vit k": 14,
    "vitamin c": 15, "ascorbic": 15,
    "epa": 42, "dha": 43,
    "carbohydrate": 4, "carb": 4,
    "sodium": 27, "potassium": 28,
}

nut_keys = list(NUTRIENT_MAP.keys())

def match_nutrient(nname):
    """Match nutrient by fuzzy or substring"""
    # Try fuzzy first
    fuzzy = get_close_matches(nname, nut_keys, cutoff=0.5, n=1)
    if fuzzy:
        return NUTRIENT_MAP[fuzzy[0]]
    # Try substring match
    for key in nut_keys:
        if key in nname or nname in key:
            return NUTRIENT_MAP[key]
    return None

dn_sql = []

for drugbank_id, drug_id in drug_map.items():
    drug_row = df_drug[df_drug["drugbank-id"] == drugbank_id]
    if drug_row.empty:
        continue
    drug_name = drug_row["name"].iloc[0]
    norm_drug = normalize(drug_name)

    spl_count = 0
    for spl in dailymed_spl.values():
        if spl_count >= 200:
            break
        names = [normalize(n) for n in spl.get("data", {}).get("name", [])]
        if not any(norm_drug in n for n in names):
            continue
        spl_count += 1
        txt = " ".join(
            spl["data"].get("warnings", []) +
            spl["data"].get("interactions", []) +
            spl["data"].get("dosage_and_administration", [])
        ).lower()
        for key in nut_keys:
            if key in txt:
                nid = NUTRIENT_MAP[key]
                if len(dn_sql) < 200:
                    dn_sql.append(
                        f"INSERT INTO drugnutrientcontraindication "
                        f"(drug_id, nutrient_id, warning_message_en, severity) "
                        f"VALUES ({drug_id}, {nid}, "
                        f"'Avoid {key} while using {drug_name}', 'medium');"
                    )

open(OUT/"drugnutrientcontraindication.sql", "w", encoding="utf-8").write("\n".join(dn_sql))

# =====================================================================
# 5) food.sql + foodnutrient.sql from USDA
# =====================================================================
food_sql = []
fn_sql = []
next_food = 1

for food in usda_foods:
    if next_food > 200:
        break
    fid = next_food
    next_food += 1

    name = food["description"]
    food_sql.append(
        f"INSERT INTO food (food_id, name, is_verified, is_active) "
        f"VALUES ({fid}, {sql_escape(name)}, TRUE, TRUE);"
    )

    # Convert fdcId to string for lookup
    nutrient_detail = usda_nutrients.get(str(food["fdcId"]), {})
    for nitem in nutrient_detail.get("foodNutrients", []):
        nname = normalize(nitem["nutrient"]["name"])
        amount = nitem.get("amount", 0)

        # match nutrient using improved function
        nid = match_nutrient(nname)
        if nid:
            fn_sql.append(
                f"INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) "
                f"VALUES ({fid}, {nid}, {amount});"
            )

open(OUT/"food.sql", "w", encoding="utf-8").write("\n".join(food_sql))
open(OUT/"foodnutrient.sql", "w", encoding="utf-8").write("\n".join(fn_sql))

print("\n✔ OPTIMIZED PIPELINE COMPLETE!")
print(f"Output folder: {OUT}")
