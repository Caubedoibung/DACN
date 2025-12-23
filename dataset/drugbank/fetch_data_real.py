import os
import json
import time
import requests
from pathlib import Path

# =========================
# CONFIG
# =========================
CACHE_DIR = Path(r"D:\dataset\real_data_cache")
CACHE_DIR.mkdir(parents=True, exist_ok=True)

USDA_API_KEY = "k0k7T0dzmxj1WRo80WXWkGCKCTxbxLcM98ZqhaOE"   # <--- IMPORTANT: ADD YOUR KEY HERE
DAILYMED_BASE = "https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json"
DAILYMED_SPL_URL = "https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/"
ICD10_URL = "https://cdn.jsdelivr.net/gh/kamillmagdy/ICD-10-CM-Codes/master/2023/icd10cm.json"

# =========================
# HELPERS
# =========================
def cache_save(name, obj):
    with open(CACHE_DIR / name, "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=2)

def cache_load(name):
    p = CACHE_DIR / name
    return json.load(open(p, encoding="utf-8")) if p.exists() else None

# =========================
# 1) Download ICD-10 CM (full disease list)
# =========================
def fetch_icd10():
    print("Downloading ICD-10...")
    r = requests.get(ICD10_URL)
    if r.status_code != 200:
        raise Exception("ICD-10 download failed")
    cache_save("icd10.json", r.json())
    print("✔ ICD-10 saved")

# =========================
# 2) Download USDA FoodData Central (2000 foods + nutrients)
# =========================
def fetch_usda():
    print("Downloading USDA foods...")

    foods = []
    page = 1
    while page <= 5:  # fetch first 5 pages (~2000 foods)
        url = f"https://api.nal.usda.gov/fdc/v1/foods/list?api_key={USDA_API_KEY}&pageSize=200&pageNumber={page}"
        r = requests.get(url)
        if r.status_code != 200:
            print(f"USDA API failed at page {page}. Status: {r.status_code}")
            print("Response:", r.text)
            raise Exception("USDA API failed")
        try:
            chunk = r.json()
        except Exception as e:
            print(f"Error parsing JSON at page {page}: {e}")
            print("Raw response:", r.text)
            raise
        if not chunk:
            print(f"No data returned at page {page}")
            break
        foods.extend(chunk)
        page += 1
        time.sleep(0.3)

    cache_save("usda_foods.json", foods)
    print(f"✔ USDA Foods saved ({len(foods)} foods)")

    # Lọc nutrient theo danh sách nutrient code
    filter_path = Path(r"D:\dataset\drugbank\nutrient_filter_list.txt")
    with open(filter_path, encoding="utf-8") as f:
        nutrient_codes = set([line.strip() for line in f if line.strip()])

    nutrients = {}
    for food in foods:
        fdc_id = food["fdcId"]
        url = f"https://api.nal.usda.gov/fdc/v1/food/{fdc_id}?api_key={USDA_API_KEY}"
        r = requests.get(url)
        if r.status_code != 200:
            continue
        food_detail = r.json()
        filtered_nutrients = [n for n in food_detail.get("foodNutrients", []) if n.get("nutrient", {}).get("number") in nutrient_codes or n.get("nutrient", {}).get("name") in nutrient_codes]
        food_detail["foodNutrients"] = filtered_nutrients
        nutrients[fdc_id] = food_detail
        time.sleep(0.2)

    cache_save("usda_nutrients.json", nutrients)
    print(f"✔ USDA nutrient profiles saved (filtered, max 200 foods)")

# =========================
# 3) Download DailyMed SPL (drug indications + warnings)
# =========================
def fetch_dailymed():
    print("Downloading DailyMed SPL index...")
    try:
        r = requests.get(DAILYMED_BASE, timeout=30)
        r.raise_for_status()
        data = r.json()
        cache_save("dailymed_index.json", data)
        print(f"✔ DailyMed index saved ({len(data.get('data', []))} items)")
    except Exception as e:
        print(f"❌ Error fetching DailyMed index: {e}")
        return

    spl_details = {}
    total = min(len(data.get("data", [])), 300)  # Lấy tối đa 300 SPL
    print(f"Downloading {total} SPL details...")
    
    for idx, item in enumerate(data.get("data", [])[:total], 1):
        spl_id = item["setid"]
        url = f"{DAILYMED_SPL_URL}{spl_id}.json"
        try:
            r = requests.get(url, timeout=10)
            if r.status_code == 200:
                spl_details[spl_id] = r.json()
                if idx % 50 == 0:
                    print(f"  Progress: {idx}/{total} SPL downloaded")
        except Exception as e:
            print(f"  Skip {spl_id}: {e}")
        time.sleep(0.1)

    cache_save("dailymed_spl.json", spl_details)
    print(f"✔ DailyMed SPL saved ({len(spl_details)} SPL details)")

# =========================
# MAIN
# =========================
if __name__ == "__main__":
    # Bỏ qua bước tải ICD-10, đã có file icd10.json trong cache
    # Chỉ tải lại USDA nutrients (foods đã có)
    
    # Load existing foods
    import json
    foods = json.load(open(CACHE_DIR / "usda_foods.json"))
    
    # Lọc nutrient theo danh sách nutrient code
    filter_path = Path(r"D:\dataset\drugbank\nutrient_filter_list.txt")
    with open(filter_path, encoding="utf-8") as f:
        nutrient_codes = set([line.strip() for line in f if line.strip()])

    nutrients = {}
    print(f"Fetching nutrients for {min(len(foods), 200)} foods...")
    for idx, food in enumerate(foods[:200], 1):  # Chỉ 200 foods đầu
        fdc_id = food["fdcId"]
        url = f"https://api.nal.usda.gov/fdc/v1/food/{fdc_id}?api_key={USDA_API_KEY}"
        try:
            r = requests.get(url, timeout=10)
            if r.status_code == 200:
                food_detail = r.json()
                filtered_nutrients = [n for n in food_detail.get("foodNutrients", []) 
                                     if n.get("nutrient", {}).get("number") in nutrient_codes 
                                     or n.get("nutrient", {}).get("name") in nutrient_codes]
                food_detail["foodNutrients"] = filtered_nutrients
                nutrients[fdc_id] = food_detail
                if idx % 20 == 0:
                    print(f"  Progress: {idx}/200")
        except Exception as e:
            print(f"  Skip {fdc_id}: {e}")
        import time
        time.sleep(0.3)

    cache_save("usda_nutrients.json", nutrients)
    print(f"✔ USDA nutrients saved ({len(nutrients)} foods with nutrients)")
    
    # fetch_dailymed()
    print("\nALL REAL DATA DOWNLOADED ✔")
