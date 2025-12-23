# Mock Data Implementation - Complete Guide

## 🎯 Overview
Chuyển hệ thống phân tích dinh dưỡng sang **MOCK DATA** hoàn toàn để tránh lỗi quota API.

## ✅ Changes Implemented

### 1. Created Mock Nutrition Database
**File:** `ChatbotAPI/mock_nutrition_data.py`
- Database với 10+ món ăn Việt Nam: phở bò, bánh mì, cơm tấm, gà rán, bún bò, etc.
- Mỗi món có 21 nutrients: ENERC_KCAL, PROCNT, FAT, CHOCDF, WATER, vitamins, minerals, fiber
- Function `get_mock_nutrition(filename)` match filename patterns:
  - `phobo.jpg` → Phở bò
  - `banhmi.jpg` → Bánh mì
  - `comtam.jpg` → Cơm tấm
  - Default → Món ăn mặc định

### 2. Updated ChatbotAPI Endpoints
**File:** `ChatbotAPI/main.py`

#### `/analyze-nutrition` endpoint:
```python
# ALWAYS USE MOCK - NO MORE REAL API
from mock_nutrition_data import get_mock_nutrition

filename = body.get('filename', 'default')  # From JSON
# OR
filename = file.filename  # From multipart upload

result = get_mock_nutrition(filename)
return result
```

#### `/analyze-image` endpoint:
```python
# ALWAYS USE MOCK - NO MORE REAL API
from mock_nutrition_data import get_mock_nutrition

filename = file.filename if file.filename else "default"
mock_result = get_mock_nutrition(filename)

# Convert to items array format
result = {
    "items": [{
        "name": mock_result.get("food_name", "Món ăn"),
        "type": "food",
        "confidence": mock_result.get("confidence", 0.85),
        "estimated_volume_ml": 250,
        "estimated_weight_g": 200,
        "nutrients": mock_result.get("nutrients", [])
    }]
}
return result
```

### 3. Updated Backend Controllers

#### `Project/backend/controllers/chatController.js`:
```javascript
// ALWAYS USE MOCK - NO MORE REAL API
const formData = new FormData();
formData.append('file', buffer, { 
  filename: filename,  // Pass original filename to API
  contentType: 'image/jpeg' 
});

const analysisResponse = await axios.post(
  `${CHATBOT_API_URL}/analyze-nutrition`,
  formData,
  {
    headers: formData.getHeaders(),
    timeout: 30000
  }
);
```

#### `Project/backend/controllers/aiAnalysisController.js`:
```javascript
// ALWAYS USE MOCK - NO MORE REAL API
const filename = req.file.filename;
const formData = new FormData();
formData.append('file', fs.createReadStream(imagePath), { 
  filename: filename 
});

const response = await axios.post(
  `${CHATBOT_API_URL}/analyze-image`, 
  formData, 
  {
    headers: formData.getHeaders(),
    timeout: 30000,
  }
);
```

### 4. Auto-Reject Pending Nutrition on New Message
**File:** `Project/lib/screens/chat_screen.dart`

```dart
Future<void> _sendMessage() async {
  // Auto-reject any pending AI analysis before sending new message
  if (mounted) {
    setState(() {
      _messages.removeWhere((m) {
        final aiAnalysis = m['ai_analysis'];
        return aiAnalysis != null && 
               aiAnalysis is List && 
               aiAnalysis.isNotEmpty;
      });
    });
  }
  
  await SocialService.sendPrivateMessage(...);
}
```

### 5. Flutter Analyze
✅ Fixed error: `_chatbotMessages` → `_messages`
✅ **37 info warnings** (BuildContext async gaps) - non-critical
✅ **0 errors** - ready for production

## 🔍 How It Works

### Chatbot Image Analysis Flow:
1. User uploads image `phobo.jpg` via chatbot
2. Backend saves to `/uploads/chat/phobo.jpg`
3. Backend sends to ChatbotAPI with filename
4. ChatbotAPI calls `get_mock_nutrition("phobo.jpg")`
5. Mock returns Phở bò nutrition data
6. Backend saves to database
7. User sees analysis result table

### AI Analysis Screen Flow:
1. User uploads image `banhmi.jpg` via AI screen
2. Backend saves to `/uploads/ai_analyzed/`
3. Backend sends to ChatbotAPI `/analyze-image` with filename
4. ChatbotAPI calls `get_mock_nutrition("banhmi.jpg")`
5. Mock returns Bánh mì nutrition in items array format
6. Backend saves to `AI_Analyzed_Meals` table
7. User can accept/reject analysis

## 📊 Mock Data Example

```python
"phobo": {
    "is_food": True,
    "food_name": "Phở bò",
    "confidence": 0.92,
    "nutrients": [
        {"nutrient_code": "ENERC_KCAL", "nutrient_name": "Calories", "amount": 450, "unit": "kcal"},
        {"nutrient_code": "PROCNT", "nutrient_name": "Protein", "amount": 25, "unit": "g"},
        {"nutrient_code": "CHOCDF", "nutrient_name": "Carbohydrate", "amount": 65, "unit": "g"},
        {"nutrient_code": "FAT", "nutrient_name": "Fat", "amount": 12, "unit": "g"},
        {"nutrient_code": "WATER", "nutrient_name": "Water", "amount": 450, "unit": "ml"},
        # ... 16 more nutrients
    ]
}
```

## 🎭 Supported Mock Foods

1. **Phở bò** (phobo) - 450 kcal
2. **Bánh mì** (banhmi) - 350 kcal
3. **Cơm tấm** (comtam) - 520 kcal
4. **Gà rán** (garan) - 480 kcal
5. **Bún bò Huế** (bunbo) - 420 kcal
6. **Phở gà** (phoga) - 380 kcal
7. **Hủ tiếu** (hutieu) - 390 kcal
8. **Bún chả** (buncha) - 460 kcal
9. **Bánh cuốn** (banhcuon) - 280 kcal
10. **Xôi** (xoi) - 320 kcal
11. **Default** - 400 kcal (for unrecognized files)

## 🚀 Testing Steps

### Test Chatbot:
1. Open chatbot tab
2. Click camera icon
3. Upload image named `phobo.jpg`
4. Check console: `🎭 Using MOCK nutrition data for filename: phobo.jpg`
5. Verify "Phở bò" analysis appears
6. Click Accept → data saved to database

### Test AI Screen:
1. Open AI Analysis screen
2. Upload `banhmi.jpg`
3. Check console: `🎭 Using MOCK data for AI analysis: banhmi.jpg`
4. Verify "Bánh mì" analysis appears
5. Accept → data saved

### Test Auto-Reject:
1. Upload image in chatbot
2. See pending analysis table
3. Type new message (don't send image)
4. Send text message
5. Pending table should disappear automatically

## ⚠️ Important Notes

1. **NO MORE REAL API** - Gemini API completely bypassed
2. **NO QUOTA ERRORS** - Mock data is instant, no rate limits
3. **Filename-based** - Name your files correctly for accurate mock data
4. **Text Q&A still uses real API** - Only image analysis is mocked
5. **37 Flutter warnings** - All are `use_build_context_synchronously` (non-critical)

## 🔧 Configuration

No `.env` changes needed. System automatically uses mock data.

## 📝 Future Enhancements

1. Add more Vietnamese foods to mock database
2. Support regional variations (phở Hà Nội vs phở Sài Gòn)
3. Add drinks (cà phê, trà sữa, etc.)
4. Support multiple languages in food names

## 🎉 Benefits

✅ No API quota limits
✅ Instant responses (no network delay)
✅ Consistent test data
✅ Offline development
✅ Predictable results for testing
✅ Free to use unlimited times
