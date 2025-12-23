import requests

API_KEY = "k0k7T0dzmxj1WRo80WXWkGCKCTxbxLcM98ZqhaOE"
url = f"https://api.nal.usda.gov/fdc/v1/foods/list?api_key={API_KEY}&pageSize=1&pageNumber=1"

r = requests.get(url)
print("Status code:", r.status_code)
try:
    print("Response:", r.json())
except Exception as e:
    print("Raw response:", r.text)
    print("Error:", e)
