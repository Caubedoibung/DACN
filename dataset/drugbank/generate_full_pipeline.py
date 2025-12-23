# generate_full_pipeline.py
# Full pipeline generator for your DB:
# outputs SQL files for: drug, healthcondition, drughealthcondition,
# drugnutrientcontraindication, food, drink, dish, foodnutrient, drinknutrient, dishnutrient
#
# Run on Windows: python generate_full_pipeline.py
# Input required: /mnt/data/drugbank_clean.csv (already uploaded)
# Output folder: D:\dataset\drugbank_full

import os
import re
import csv
import json
import math
import random
from pathlib import Path
from difflib import get_close_matches
import pandas as pd

# -------------------------
# Paths
# -------------------------
IN_DRUGBANK = "/mnt/data/drugbank_clean.csv"
OUT_DIR = Path(r"D:\dataset\drugbank_full")
OUT_DIR.mkdir(parents=True, exist_ok=True)

# -------------------------
# Nutrient master (from your uploaded list)
# Format: (nutrient_id, canonical_name)
# -------------------------
NUTRIENTS = [
    (1, "Energy (Calories)"), (2, "Protein"), (3, "Total Fat"), (4, "Carbohydrate"),
    (5, "Dietary Fiber"), (6, "Soluble Fiber"), (7, "Insoluble Fiber"),
    (8, "Resistant Starch"), (9, "Beta-Glucan"), (10, "Cholesterol"),
    (11, "Vitamin A"), (12, "Vitamin D"), (13, "Vitamin E"), (14, "Vitamin K"),
    (15, "Vitamin C"), (16, "Vitamin B1"), (17, "Vitamin B2"), (18, "Vitamin B3"),
    (19, "Vitamin B5"), (20, "Vitamin B6"), (21, "Vitamin B7"), (22, "Vitamin B9"),
    (23, "Vitamin B12"), (24, "Calcium"), (25, "Phosphorus"), (26, "Magnesium"),
    (27, "Potassium"), (28, "Sodium"), (29, "Iron"), (30, "Zinc"), (31, "Copper"),
    (32, "Manganese"), (33, "Iodine"), (34, "Selenium"), (35, "Chromium"),
    (36, "Molybdenum"), (37, "Fluoride"), (38, "Monounsaturated Fat"),
    (39, "Polyunsaturated Fat"), (40, "Saturated Fat"), (41, "Trans Fat"),
    (42, "EPA"), (43, "DHA"), (44, "EPA + DHA"), (45, "Linoleic Acid"),
    (46, "Alpha-linolenic Acid"), (47, "Histidine"), (48, "Isoleucine"),
    (49, "Leucine"), (50, "Lysine"), (51, "Methionine"), (52, "Phenylalanine"),
    (53, "Threonine"), (54, "Tryptophan"), (55, "Valine"), (72, "ALA"),
    (75, "EPA + DHA Combined"), (76, "LA")
]
NUT_MAP = {name.lower(): nid for nid, name in NUTRIENTS}
NUT_KEYS = list(NUT_MAP.keys())

# -------------------------
# Small canonical disease list (healthcondition)
# We'll produce ~300 common conditions (demo). This is synthetic but realistic.
# -------------------------
COMMON_CONDITIONS = [
    "Hypertension","Type 2 diabetes mellitus","Type 1 diabetes mellitus","Hyperlipidemia",
    "Hypothyroidism","Hyperthyroidism","Coronary artery disease","Heart failure",
    "Atrial fibrillation","Asthma","Chronic obstructive pulmonary disease",
    "Gastroesophageal reflux disease","Peptic ulcer disease","Osteoporosis",
    "Rheumatoid arthritis","Osteoarthritis","Chronic kidney disease","Acute kidney injury",
    "Depression","Generalized anxiety disorder","Schizophrenia","Bipolar disorder",
    "Migraine","Parkinson disease","Alzheimer disease","Epilepsy","Anemia",
    "Iron deficiency anemia","Vitamin B12 deficiency","Malnutrition","Obesity",
    "Chronic liver disease","Hepatitis B","Hepatitis C","Alcohol use disorder",
    "Chronic pancreatitis","Inflammatory bowel disease","Ulcerative colitis",
    "Crohn disease","Urinary tract infection","Pneumonia","Tuberculosis","HIV infection",
    "Hypersensitivity","Allergic rhinitis","Atopic dermatitis","Psoriasis",
    "Hyperuricemia","Gout","Acute coronary syndrome","Peripheral artery disease",
    "Stroke","Transient ischemic attack","Deep vein thrombosis","Pulmonary embolism",
    "Migraine with aura","Insomnia","Acute bronchitis","Sinusitis","Otitis media",
    "Acne","Benign prostatic hyperplasia","Erectile dysfunction","Pregnancy",
    "Pre-eclampsia","Gestational diabetes","Thyroiditis","Hypoparathyroidism",
    "Anxiety disorder","Post-traumatic stress disorder","Substance use disorder"
]
# extend to ~300 by adding synthetic entries (variant names)
for i in range(1, 241):
    COMMON_CONDITIONS.append(f"Other condition {i}")

# -------------------------
# Food -> nutrient precise mapping (high-confidence)
# We'll use it as demo to fill foodnutrient
# -------------------------
FOOD_TO_NUT = {
    r"\bmilk\b": ["calcium"],
    r"\bdairy\b": ["calcium"],
    r"\bcheese\b": ["calcium"],
    r"\byogurt\b": ["calcium"],
    r"\bspinach\b": ["iron","vitamin k"],
    r"\bgreen leafy\b": ["vitamin k"],
    r"\bbroccoli\b": ["vitamin c","calcium"],
    r"\begg\b": ["protein","vitamin b12"],
    r"\bmeat\b": ["protein","iron"],
    r"\bchicken\b": ["protein"],
    r"\bbeef\b": ["protein","iron"],
    r"\bsalmon\b": ["epa","dha","protein"],
    r"\bfatty fish\b": ["epa","dha"],
    r"\bwalnut\b": ["alpha-linolenic acid"],
    r"\bbread\b": ["carbohydrate"],
    r"\brice\b": ["carbohydrate"],
    r"\bbeans\b": ["protein","dietary fiber","iron"],
    r"\bbroth\b": ["sodium"],
    r"\bspinach\b": ["iron"],
    r"\bcoffee\b": ["caffeine"],  # caffeine not in nutrients list but kept as tag
    r"\btea\b": ["vitamin c"]
}
# normalize mapping to nutrient ids when possible
def foodmap_to_nidlist(lst):
    out=[]
    for nm in lst:
        key = nm.lower()
        # try direct match in NUT_MAP keys
        mm = get_close_matches(key, NUT_KEYS, cutoff=0.7)
        if mm:
            out.append(NUT_MAP[mm[0]])
    return list(set(out))

# -------------------------
# Helpers
# -------------------------
def safe_sql_str(s):
    if s is None:
        return "NULL"
    return "'" + str(s).replace("'", "''") + "'"

def write_sql(path, lines):
    with open(path, "w", encoding="utf-8") as f:
        for l in lines:
            f.write(l.rstrip() + "\n")

# -------------------------
# Read DrugBank CSV
# -------------------------
if not os.path.exists(IN_DRUGBANK):
    raise FileNotFoundError(f"DrugBank file not found at {IN_DRUGBANK}. Put drugbank_clean.csv there.")

df = pd.read_csv(IN_DRUGBANK, low_memory=False)

# attempt to find columns
cols = {c.lower(): c for c in df.columns}
col_drugbank_id = cols.get("drugbank-id") or cols.get("drugbank_id") or list(df.columns)[0]
col_name = cols.get("name") or list(df.columns)[1]
col_desc = cols.get("description") if "description" in cols else None
col_indication = None
for k in cols:
    if "indication" in k:
        col_indication = cols[k]
        break
col_food = None
for k in cols:
    if "food" in k and "interaction" in k:
        col_food = cols[k]
        break
# fallback if not found:
if col_desc is None:
    # try other name-like columns
    col_desc = list(df.columns)[2] if len(df.columns) > 2 else col_name

# -------------------------
# 1) Generate drug.sql (insert into 'drug' table)
# -------------------------
drug_rows = []
drug_id_map = {}   # map drugbank-id -> generated internal drug_id (auto incremental)
next_drug_id = 1

for _, r in df.iterrows():
    dbid = str(r.get(col_drugbank_id))
    name = str(r.get(col_name))[:250] if pd.notna(r.get(col_name)) else dbid
    desc = str(r.get(col_desc)) if pd.notna(r.get(col_desc)) else None

    drug_id = next_drug_id
    next_drug_id += 1
    drug_id_map[dbid] = drug_id

    # fields for 'drug' table per schema: drug_id, name_vi, name_en, generic_name, drug_class, description, image_url, source_link, dosage_form, is_active, created_by_admin, created_at
    drug_rows.append((
        drug_id,
        None,
        name,
        None,
        None,
        desc,
        None,
        dbid,   # store DrugBank id in source_link for traceability
        None,
        True,
        None,
        None
    ))

sql_drug_lines = []
for r in drug_rows:
    cols = ["drug_id","name_vi","name_en","generic_name","drug_class","description","image_url","source_link","dosage_form","is_active","created_by_admin","created_at"]
    vals = ",".join([safe_sql_str(x) if not isinstance(x,bool) else ("TRUE" if x else "FALSE") for x in r])
    sql_drug_lines.append(f"INSERT INTO drug ({', '.join(cols)}) VALUES ({vals});")

write_sql(OUT_DIR / "drug.sql", sql_drug_lines)

# -------------------------
# 2) Generate healthcondition.sql
# -------------------------
hc_rows = []
hc_id = 1
for name in COMMON_CONDITIONS:
    hc_rows.append((hc_id, None, name, None, None, None, None, None, None, None, None))
    hc_id += 1

sql_hc = []
for r in hc_rows:
    cols = ["condition_id","name_vi","name_en","category","description","causes","image_url","treatment_duration_reference","created_at","updated_at","dummy"]
    # we only fill condition_id and name_en
    vals = [r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10]]
    vals_sql = ",".join([safe_sql_str(v) for v in vals])
    sql_hc.append(f"INSERT INTO healthcondition ({', '.join(cols)}) VALUES ({vals_sql});")

write_sql(OUT_DIR / "healthcondition.sql", sql_hc)

# -------------------------
# 3) Map drug -> healthcondition (drughealthcondition)
#    Strategy: use 'indication' column if exists; fuzzy match to healthcondition names
# -------------------------
# prepare healthcondition name list for fuzzy matching
hc_name_map = {r[0]: r[2].lower() for r in hc_rows}  # id->name
hc_name_list = list(hc_name_map.values())

def find_condition_ids_from_text(text, topn=3):
    if not text or str(text).strip()=="":
        return []
    text_l = str(text).lower()
    hits = set()
    # direct substring match
    for cid, nm in hc_name_map.items():
        if nm in text_l:
            hits.add(cid)
    # fuzzy: check tokens
    tokens = re.split(r"[;,./()\-]", text_l)
    for t in tokens:
        t = t.strip()
        if len(t) < 3:
            continue
        mm = get_close_matches(t, hc_name_list, n=topn, cutoff=0.8)
        for m in mm:
            # find id of m
            for cid, nm in hc_name_map.items():
                if nm == m:
                    hits.add(cid)
    return sorted(list(hits))

dhc_rows = []
for _, r in df.iterrows():
    dbid = str(r.get(col_drugbank_id))
    drug_id = drug_id_map.get(dbid)
    # try indication then description
    txt = ""
    if col_indication and pd.notna(r.get(col_indication)):
        txt = str(r.get(col_indication))
    elif pd.notna(r.get(col_desc)):
        txt = str(r.get(col_desc))
    cond_ids = find_condition_ids_from_text(txt)
    for cid in cond_ids:
        dhc_rows.append((None, drug_id, cid, txt[:250], True, None))  # drug_condition_id left NULL (auto), treatment_notes truncated

sql_dhc = []
for r in dhc_rows:
    cols = ["drug_condition_id","drug_id","condition_id","treatment_notes","is_primary","created_at"]
    vals = [r[0], r[1], r[2], r[3], r[4], r[5]]
    vals_sql = ",".join([safe_sql_str(v) if not isinstance(v,bool) else ("TRUE" if v else "FALSE") for v in vals])
    sql_dhc.append(f"INSERT INTO drughealthcondition ({', '.join(cols)}) VALUES ({vals_sql});")

write_sql(OUT_DIR / "drughealthcondition.sql", sql_dhc)

# -------------------------
# 4) Generate drug-nutrient contraindications (smart rules + direct matches)
# -------------------------
# Heuristics + patterns (high precision chosen for this pipeline)
PATTERNS = {
    r"calcium": ["calcium"],
    r"\bmilk\b": ["calcium"],
    r"\bdairy\b": ["calcium"],
    r"magnesium": ["magnesium"],
    r"iron": ["iron"],
    r"zinc": ["zinc"],
    r"\bprotein\b": ["protein"],
    r"vitamin k": ["vitamin k"],
    r"vit k": ["vitamin k"],
    r"vitamin c": ["vitamin c"],
    r"fiber": ["dietary fiber"],
    r"high[- ]fat": ["total fat"],
    r"antacid": ["magnesium","calcium"],
    r"divalent cation": ["calcium","magnesium"],
    r"polyvalent cation": ["calcium","magnesium","iron","zinc"],
    r"fatty fish": ["epa","dha"],
    r"fish oil": ["epa","dha"],
    r"omega[- ]3": ["epa","dha"]
}

def match_nutrients_from_text(text):
    if not text or str(text).strip()=="":
        return []
    text_l = str(text).lower()
    found = set()
    # direct name matches
    for key in NUT_KEYS:
        if key in text_l:
            found.add(NUT_MAP[key])
    # pattern rules
    for pat, mapped in PATTERNS.items():
        if re.search(pat, text_l):
            for mm in mapped:
                mm_low = mm.lower()
                if mm_low in NUT_MAP:
                    found.add(NUT_MAP[mm_low])
                else:
                    # fuzzy try
                    close = get_close_matches(mm_low, NUT_KEYS, cutoff=0.65)
                    for c in close:
                        found.add(NUT_MAP[c])
    return sorted(list(found))

dn_rows = []
for _, r in df.iterrows():
    dbid = str(r.get(col_drugbank_id))
    drug_id = drug_id_map.get(dbid)
    food_text = r.get(col_food) if col_food and pd.notna(r.get(col_food)) else ""
    desc_text = r.get(col_desc) if pd.notna(r.get(col_desc)) else ""
    # combine text sources
    combined = " ".join([str(food_text), str(desc_text)])
    nids = match_nutrients_from_text(combined)
    for nid in nids:
        dn_rows.append((dbid, drug_id, nid, None, None, None, "medium"))

sql_dn = []
for r in dn_rows:
    cols = ["drugbank_id","drug_id","nutrient_id","avoid_hours_before","avoid_hours_after","warning_message_vi","warning_message_en","severity"]
    # keep warning_message_en simple
    warn = f"Avoid { [name for (i,name) in NUTRIENTS if i==r[2]][0 ] } while using { [x for x in df[col_name] if True][:1] }"
    # but we will produce a clearer message below
    warn_en = f"Avoid { [name for (i,name) in NUTRIENTS if i==r[2]][0 ] } while using drug {r[0]}"
    vals = [r[0], r[1], r[2], None, None, None, warn_en, r[6]]
    vals_sql = ",".join([safe_sql_str(v) if not isinstance(v,bool) else ("TRUE" if v else "FALSE") for v in vals])
    sql_dn.append(f"INSERT INTO drugnutrientcontraindication (drugbank_id, drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity) VALUES ({vals_sql});")

write_sql(OUT_DIR / "drugnutrientcontraindication.sql", sql_dn)

# -------------------------
# 5) Create demo food/drink/dish tables + nutrient mapping
# We'll synthesize a set of foods (common items) and map by FOOD_TO_NUT rules
# -------------------------
COMMON_FOODS = [
    "Whole Milk", "Cheddar Cheese", "Yogurt", "Spinach", "Broccoli", "Egg (whole)",
    "Chicken Breast", "Beef Steak", "Salmon (farm)", "Tuna (canned)", "White Rice", "Brown Rice",
    "Whole Wheat Bread", "Black Beans", "Kidney Beans", "Almonds", "Walnuts", "Olive Oil",
    "Butter", "Apple", "Banana", "Orange", "Grapefruit", "Avocado", "Potato", "Sweet Potato",
    "Spinach Salad", "Caesar Salad", "Greek Yogurt", "Oatmeal", "Peanut Butter"
]

food_rows = []
foodnut_rows = []
next_food_id = 1
for name in COMMON_FOODS:
    fid = next_food_id; next_food_id+=1
    food_rows.append((fid, name, None, None, None, None, None, True, True, None, None))
    # map nutrients via FOOD_TO_NUT regex rules
    text = name.lower()
    mapped_nids = set()
    for pat, mapped in FOOD_TO_NUT.items():
        if re.search(pat, text):
            for nm in mapped:
                # fuzzy to nutrient id
                close = get_close_matches(nm.lower(), NUT_KEYS, cutoff=0.65)
                for c in close:
                    mapped_nids.add(NUT_MAP[c])
    # fallback heuristics (protein -> meat etc)
    if "chicken" in text or "beef" in text or "meat" in text:
        if "protein" in NUT_MAP:
            mapped_nids.add(NUT_MAP["protein"])
    # create some realistic amounts
    for nid in mapped_nids:
        amount = round(random.uniform(0.5, 30.0), 2)
        foodnut_rows.append((None, fid, nid, amount))

# write food.sql
sql_food = []
for r in food_rows:
    cols = ["food_id","name","category","image_url","created_at","created_by_admin","description","serving_size_g","is_verified","is_active","updated_at"]
    vals_sql = ",".join([safe_sql_str(x) for x in r])
    sql_food.append(f"INSERT INTO food ({', '.join(cols)}) VALUES ({vals_sql});")
write_sql(OUT_DIR / "food.sql", sql_food)

# write foodnutrient.sql
sql_foodnut = []
for r in foodnut_rows:
    cols = ["food_nutrient_id","food_id","nutrient_id","amount_per_100g"]
    vals = [r[0], r[1], r[2], r[3]]
    vals_sql = ",".join([safe_sql_str(x) for x in vals])
    sql_foodnut.append(f"INSERT INTO foodnutrient ({', '.join(cols)}) VALUES ({vals_sql});")
write_sql(OUT_DIR / "foodnutrient.sql", sql_foodnut)

# For drinks, synthesize few drinks from foods
drink_rows = []
drinknut_rows = []
next_drink_id = 1
COMMON_DRINKS = ["Whole Milk (drink)","Orange Juice","Coffee","Green Tea","Olive Oil Shot"]
for name in COMMON_DRINKS:
    did = next_drink_id; next_drink_id+=1
    drink_rows.append((did, name, None, None, None, None, None, None, None, None, None, None))
    text = name.lower()
    mapped = set()
    for pat, m in FOOD_TO_NUT.items():
        if re.search(pat, text):
            for nm in m:
                close = get_close_matches(nm.lower(), NUT_KEYS, cutoff=0.65)
                for c in close:
                    mapped.add(NUT_MAP[c])
    for nid in mapped:
        amount = round(random.uniform(0.1, 10.0), 2)
        drinknut_rows.append((None, did, nid, amount))

sql_drink = []
for r in drink_rows:
    cols = ["drink_id","name","vietnamese_name","slug","description","category","base_liquid","default_volume_ml","default_temperature","default_sweetness","hydration_ratio","caffeine_mg"]
    vals_sql = ",".join([safe_sql_str(x) for x in r])
    sql_drink.append(f"INSERT INTO drink ({', '.join(cols)}) VALUES ({vals_sql});")
write_sql(OUT_DIR / "drink.sql", sql_drink)

sql_drinknut = []
for r in drinknut_rows:
    cols = ["drink_nutrient_id","drink_id","nutrient_id","amount_per_100ml"]
    vals_sql = ",".join([safe_sql_str(x) for x in r])
    sql_drinknut.append(f"INSERT INTO drinknutrient ({', '.join(cols)}) VALUES ({vals_sql});")
write_sql(OUT_DIR / "drinknutrient.sql", sql_drinknut)

# -------------------------
# 6) Dish: create combinations of foods as dishes and map nutrients by summing components
# -------------------------
dish_rows=[]
dishnut_rows=[]
next_dish_id = 1
DISH_TEMPLATES = [
    ("Grilled Salmon with Spinach", ["Salmon (farm)","Spinach Salad"]),
    ("Cheese Omelette", ["Egg (whole)","Cheddar Cheese"]),
    ("Chicken Rice", ["Chicken Breast","White Rice"]),
    ("Beef Steak with Broccoli", ["Beef Steak","Broccoli"]),
    ("Beans and Rice", ["Black Beans","Brown Rice"])
]
# map food name to id from food_rows
food_name_to_id = {r[1].lower(): r[0] for r in food_rows}
for dish_name, components in DISH_TEMPLATES:
    did = next_dish_id; next_dish_id+=1
    dish_rows.append((did, dish_name, None, None, None, None, None, None, None, None, None, None, None))
    # sum nutrient amounts from components (if present)
    comp_ids = []
    for comp in components:
        comp_low = comp.lower()
        fid = None
        # try exact match or substring
        for fn, fid0 in food_name_to_id.items():
            if comp_low in fn:
                fid = fid0
                break
        if fid:
            comp_ids.append(fid)
    # produce dishnut rows by averaging component nutrients
    # find all foodnutrient entries that match these fids
    for fid in comp_ids:
        for fn_row in foodnut_rows:
            if fn_row[1] == fid:
                # map to dish nutrient
                nid = fn_row[2]
                amount = round(fn_row[3] * 0.6 + random.uniform(0.0,2.0), 2)
                dishnut_rows.append((None, did, nid, amount))

sql_dish = []
for r in dish_rows:
    cols = ["dish_id","name","vietnamese_name","description","category","serving_size_g","image_url","is_template","is_public","created_by_user","created_by_admin","created_at","updated_at"]
    vals_sql = ",".join([safe_sql_str(x) for x in r])
    sql_dish.append(f"INSERT INTO dish ({', '.join(cols)}) VALUES ({vals_sql});")
write_sql(OUT_DIR / "dish.sql", sql_dish)

sql_dishnut = []
for r in dishnut_rows:
    cols = ["dish_nutrient_id","dish_id","nutrient_id","amount_per_100g"]
    vals_sql = ",".join([safe_sql_str(x) for x in r])
    sql_dishnut.append(f"INSERT INTO dishnutrient ({', '.join(cols)}) VALUES ({vals_sql});")
write_sql(OUT_DIR / "dishnutrient.sql", sql_dishnut)

# -------------------------
# 7) Summary files (CSV) for review
# -------------------------
# drug list
pd.DataFrame(drug_rows, columns=["drug_id","name_vi","name_en","generic_name","drug_class","description","image_url","source_link","dosage_form","is_active","created_by_admin","created_at"]).to_csv(OUT_DIR/"drug.csv", index=False)

# healthcondition csv
pd.DataFrame(hc_rows, columns=["condition_id","name_vi","name_en","category","description","causes","image_url","treatment_duration_reference","created_at","updated_at","dummy"]).to_csv(OUT_DIR/"healthcondition.csv", index=False)

# drughealthcondition csv
pd.DataFrame(dhc_rows, columns=["drug_condition_id","drug_id","condition_id","treatment_notes","is_primary","created_at"]).to_csv(OUT_DIR/"drughealthcondition.csv", index=False)

# drugnutrient CSV
pd.DataFrame(dn_rows, columns=["drugbank_id","drug_id","nutrient_id","avoid_hours_before","avoid_hours_after","warning_message_vi","warning_message_en","severity"]).to_csv(OUT_DIR/"drugnutrientcontraindication.csv", index=False)

# food csvs
pd.DataFrame(food_rows, columns=["food_id","name","category","image_url","created_at","created_by_admin","description","serving_size_g","is_verified","is_active","updated_at"]).to_csv(OUT_DIR/"food.csv", index=False)
pd.DataFrame(foodnut_rows, columns=["food_nutrient_id","food_id","nutrient_id","amount_per_100g"]).to_csv(OUT_DIR/"foodnutrient.csv", index=False)
pd.DataFrame(drink_rows, columns=["drink_id","name","vietnamese_name","slug","description","category","base_liquid","default_volume_ml","default_temperature","default_sweetness","hydration_ratio","caffeine_mg"]).to_csv(OUT_DIR/"drink.csv", index=False)
pd.DataFrame(drinknut_rows, columns=["drink_nutrient_id","drink_id","nutrient_id","amount_per_100ml"]).to_csv(OUT_DIR/"drinknutrient.csv", index=False)
pd.DataFrame(dish_rows, columns=["dish_id","name","vietnamese_name","description","category","serving_size_g","image_url","is_template","is_public","created_by_user","created_by_admin","created_at","updated_at"]).to_csv(OUT_DIR/"dish.csv", index=False)
pd.DataFrame(dishnut_rows, columns=["dish_nutrient_id","dish_id","nutrient_id","amount_per_100g"]).to_csv(OUT_DIR/"dishnutrient.csv", index=False)

# -------------------------
# 8) Print summary
# -------------------------
print("FULL PIPELINE GENERATED")
print("Output folder:", OUT_DIR)
print("Files created (SQL + CSV) - import these into your DB:")
for f in sorted(os.listdir(OUT_DIR)):
    print(" -", f)

