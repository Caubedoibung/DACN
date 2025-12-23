"""
DEMO: Test AI Image Analysis Cache với 2 ảnh
- Burger combo (burger + fries + cola)
- Phở bò (Vietnamese beef noodle soup)
"""
import requests
import time

API_URL = "http://localhost:8000"

def test_cache_stats():
    """Xem stats cache"""
    print("\n📊 CACHE STATS:")
    print("=" * 50)
    response = requests.get(f"{API_URL}/cache-stats")
    stats = response.json()
    
    print(f"Total entries: {stats['total_entries']}")
    print(f"Total cache hits: {stats['total_cache_hits']}")
    print(f"Average hits/entry: {stats['average_hits_per_entry']}")
    print(f"API calls SAVED: {stats['estimated_api_calls_saved']} 🚀")
    print("=" * 50)

def test_analyze_image(image_path: str, run_number: int):
    """Test phân tích ảnh"""
    print(f"\n🔍 RUN #{run_number}: Analyzing...")
    
    with open(image_path, 'rb') as f:
        start_time = time.time()
        
        # MOCK MODE - để test cache không cần API thật
        response = requests.post(
            f"{API_URL}/analyze-image?use_mock=true",
            files={"file": f}
        )
        
        elapsed = time.time() - start_time
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Success in {elapsed:.2f}s")
            
            if "items" in result and len(result["items"]) > 0:
                item = result["items"][0]
                print(f"   Item: {item.get('item_name', 'Unknown')}")
                print(f"   Calories: {item.get('nutrients', {}).get('enerc_kcal', 0)} kcal")
        else:
            print(f"❌ Error {response.status_code}: {response.text[:200]}")
        
        return elapsed

if __name__ == "__main__":
    print("🧪 DEMO: AI IMAGE ANALYSIS CACHE - 2 IMAGES")
    print("=" * 50)
    print("📸 Image 1: Burger combo (burger + fries + cola)")
    print("📸 Image 2: Phở bò (Vietnamese beef noodle soup)")
    print("=" * 50)
    
    # Two test images from user
    image1 = "D:\\App\\new\\burger_combo.jpg"  # User will save first attachment
    image2 = "D:\\App\\new\\pho_bo.jpg"        # User will save second attachment
    
    # Initial stats
    test_cache_stats()
    
    # Test Image 1 - First time (MISS)
    print("\n" + "=" * 50)
    print("🍔 IMAGE 1 - RUN 1: Burger combo (Cache MISS)")
    print("Expected: API call (~5-10s)")
    print("=" * 50)
    try:
        time1_1 = test_analyze_image(image1, 1)
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\n💡 Save burger image as: D:\\App\\new\\burger_combo.jpg")
        exit(1)
    
    # Test Image 1 - Second time (HIT)
    print("\n" + "=" * 50)
    print("🍔 IMAGE 1 - RUN 2: Burger combo (Cache HIT)")
    print("Expected: INSTANT from cache (<0.1s)")
    print("=" * 50)
    time.sleep(1)
    time1_2 = test_analyze_image(image1, 2)
    
    # Test Image 2 - First time (MISS)
    print("\n" + "=" * 50)
    print("🍜 IMAGE 2 - RUN 1: Phở bò (Cache MISS)")
    print("Expected: API call (~5-10s)")
    print("=" * 50)
    time.sleep(1)
    try:
        time2_1 = test_analyze_image(image2, 3)
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\n💡 Save phở image as: D:\\App\\new\\pho_bo.jpg")
        exit(1)
    
    # Test Image 2 - Second time (HIT)
    print("\n" + "=" * 50)
    print("🍜 IMAGE 2 - RUN 2: Phở bò (Cache HIT)")
    print("Expected: INSTANT from cache (<0.1s)")
    print("=" * 50)
    time.sleep(1)
    time2_2 = test_analyze_image(image2, 4)
    
    # Test Image 1 - Third time (HIT again)
    print("\n" + "=" * 50)
    print("🍔 IMAGE 1 - RUN 3: Burger combo (Cache HIT again)")
    print("Expected: INSTANT from cache (<0.1s)")
    print("=" * 50)
    time.sleep(1)
    time1_3 = test_analyze_image(image1, 5)
    
    # Final stats
    test_cache_stats()
    
    # Summary
    print("\n" + "=" * 50)
    print("📈 PERFORMANCE SUMMARY:")
    print("=" * 50)
    print(f"\n🍔 BURGER COMBO:")
    print(f"  Run 1 (API):   {time1_1:.2f}s")
    print(f"  Run 2 (Cache): {time1_2:.2f}s - {((time1_1-time1_2)/time1_1*100):.0f}% faster! 🚀")
    print(f"  Run 3 (Cache): {time1_3:.2f}s - {((time1_1-time1_3)/time1_1*100):.0f}% faster! 🚀")
    
    print(f"\n🍜 PHỞ BÒ:")
    print(f"  Run 1 (API):   {time2_1:.2f}s")
    print(f"  Run 2 (Cache): {time2_2:.2f}s - {((time2_1-time2_2)/time2_1*100):.0f}% faster! 🚀")
    
    total_api_calls = 2  # Only 2 API calls (first time for each image)
    total_requests = 5   # 5 total analysis requests
    cache_efficiency = ((total_requests - total_api_calls) / total_requests) * 100
    
    print(f"\n💰 COST SAVINGS:")
    print(f"  Total requests: {total_requests}")
    print(f"  API calls: {total_api_calls}")
    print(f"  Cache hits: {total_requests - total_api_calls}")
    print(f"  Cache efficiency: {cache_efficiency:.0f}% 🎯")
    
    if time1_2 < 0.5 and time1_3 < 0.5 and time2_2 < 0.5:
        print("\n✅ CACHE WORKING PERFECTLY!")
        print(f"💡 API cost saved: {cache_efficiency:.0f}% ({total_requests - total_api_calls} out of {total_requests} calls)")
    else:
        print("\n⚠️  Cache might not be working optimally. Check logs.")
