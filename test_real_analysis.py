"""
Test phân tích ảnh THẬT (không dùng mock) để kiểm tra nutrients
"""
import requests
import json

API_URL = "http://localhost:8000"

def test_real_analysis(image_path: str, image_name: str):
    """Test với API thật"""
    print(f"\n{'='*60}")
    print(f"📸 ANALYZING: {image_name}")
    print(f"{'='*60}")
    
    with open(image_path, 'rb') as f:
        # Không dùng mock - gọi API thật
        response = requests.post(
            f"{API_URL}/analyze-image",  # Không có ?use_mock=true
            files={"file": f}
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ SUCCESS!")
            
            # Pretty print kết quả
            print(f"\n📋 FULL RESPONSE:")
            print(json.dumps(result, indent=2, ensure_ascii=False))
            
            # Kiểm tra nutrients
            if "items" in result and len(result["items"]) > 0:
                for idx, item in enumerate(result["items"], 1):
                    print(f"\n🍽️  ITEM #{idx}: {item.get('item_name', 'Unknown')}")
                    print(f"   Type: {item.get('item_type', 'N/A')}")
                    print(f"   Confidence: {item.get('confidence_score', 0)}%")
                    print(f"   Weight: {item.get('estimated_weight_g', 0)}g")
                    print(f"   Water: {item.get('water_ml', 0)}ml")
                    
                    nutrients = item.get('nutrients', {})
                    print(f"\n   💊 NUTRIENTS (Total: {len(nutrients)}):")
                    
                    # Group nutrients
                    macros = ['enerc_kcal', 'procnt', 'fat', 'chocdf', 'fibtg', 'water']
                    vitamins = [k for k in nutrients.keys() if k.startswith('vit') or k.upper().startswith('VIT')]
                    minerals = [k for k in nutrients.keys() if k.startswith('min_') or k.startswith('MIN_')]
                    fatty_acids = ['total_fat', 'mufa', 'pufa', 'la', 'ala', 'epa_dha']
                    
                    print(f"\n   📊 MACRONUTRIENTS:")
                    for nutrient in macros:
                        if nutrient in nutrients or nutrient.upper() in nutrients:
                            key = nutrient if nutrient in nutrients else nutrient.upper()
                            print(f"      {key}: {nutrients[key]}")
                    
                    print(f"\n   🌟 VITAMINS ({len(vitamins)}):")
                    for nutrient in vitamins:
                        print(f"      {nutrient}: {nutrients[nutrient]}")
                    
                    print(f"\n   ⚡ MINERALS ({len(minerals)}):")
                    for nutrient in minerals:
                        print(f"      {nutrient}: {nutrients[nutrient]}")
                    
                    print(f"\n   🥑 FATTY ACIDS:")
                    for nutrient in fatty_acids:
                        if nutrient in nutrients or nutrient.upper() in nutrients:
                            key = nutrient if nutrient in nutrients else nutrient.upper()
                            print(f"      {key}: {nutrients[key]}")
                    
                    print(f"\n   ✅ TOTAL NUTRIENTS RETURNED: {len(nutrients)}")
                    
        else:
            print(f"❌ ERROR {response.status_code}")
            print(response.text)

if __name__ == "__main__":
    print("🧪 TESTING REAL API ANALYSIS (NO MOCK)")
    print("=" * 60)
    print("⚠️  WARNING: This will use real API calls!")
    print("   If quota exhausted, test will fail.")
    print("=" * 60)
    
    input("\nPress Enter to continue or Ctrl+C to cancel...")
    
    # Test 2 images
    test_real_analysis("D:\\App\\new\\burger_combo.jpg", "Burger Combo")
    test_real_analysis("D:\\App\\new\\pho_bo.jpg", "Phở Bò")
    
    print("\n" + "=" * 60)
    print("✅ TESTING COMPLETE!")
    print("=" * 60)
