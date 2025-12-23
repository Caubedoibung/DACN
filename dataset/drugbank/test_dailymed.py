import requests
import json
from pathlib import Path

# Load index
idx = json.load(open(r'd:\dataset\real_data_cache\dailymed_index.json'))
print(f'Total items in index: {len(idx["data"])}')

# Test first SPL
first = idx['data'][0]
print(f'\nFirst item: {first}')

spl_id = first['setid']
url = f"https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/{spl_id}.json"
print(f'\nTesting URL: {url}')

try:
    headers = {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    r = requests.get(url, timeout=15, headers=headers)
    print(f'Status: {r.status_code}')
    
    if r.status_code == 200:
        data = r.json()
        print(f'Response keys: {list(data.keys())}')
        print(f'Data structure: {type(data)}')
        if 'data' in data:
            print(f'Data.data keys: {list(data["data"].keys())[:10]}')
    else:
        print(f'Error: {r.text[:200]}')
except Exception as e:
    print(f'Exception: {e}')
