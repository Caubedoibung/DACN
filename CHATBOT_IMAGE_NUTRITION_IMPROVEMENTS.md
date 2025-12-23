# CHATBOT IMAGE NUTRITION ANALYSIS - IMPROVEMENTS SUMMARY

## 📋 Tổng Quan Thay Đổi

Đã hoàn thành cải tiến hệ thống phân tích dinh dưỡng hình ảnh trong chatbot với các tính năng sau:

### ✅ 1. Sửa Lỗi Hiển Thị Hình Ảnh Trong Chatbot

**Vấn đề:** Hình ảnh không hiển thị trong chatbot khi gửi

**Giải pháp:**
- Thêm hàm `_buildImageWidget()` để xử lý cả local file và network image
- Tự động phát hiện đường dẫn local file vs server path
- Kiểm tra `File.existsSync()` trước khi hiển thị local file
- Fallback sang network image nếu local không tồn tại

**Files thay đổi:**
- `lib/screens/chat_screen.dart`: Thêm helper function `_buildImageWidget()`

```dart
Widget _buildImageWidget(String? imageUrl, {double? width, double? height}) {
  // Check local file first
  if (!imageUrl.startsWith('http') && !imageUrl.startsWith('/uploads')) {
    final file = File(imageUrl);
    if (file.existsSync()) {
      return Image.file(file, ...);
    }
  }
  
  // Fallback to network image
  final url = imageUrl.startsWith('http') ? imageUrl : '${ApiConfig.baseUrl}$imageUrl';
  return Image.network(url, ...);
}
```

### ✅ 2. Hiển Thị Bảng Dinh Dưỡng Trong Chatbot

**Vấn đề:** Chatbot chỉ hiển thị text, không có bảng trực quan

**Giải pháp:**
- Chuyển từ text sang `NutritionResultTable` widget
- Hiển thị nutrition table giống như màn hình AI Analysis
- Thêm hàm `_buildAiAnalysisResult()` để render table

**Files thay đổi:**
- `lib/screens/chat_screen.dart`: 
  - Thay `_buildAiAnalysisActions()` bằng `_buildAiAnalysisResult()`
  - Thêm helper functions: `_getNutrientName()`, `_getNutrientUnit()`
  - Hiển thị nutrition table cho mỗi món trong AI analysis

```dart
Widget _buildAiAnalysisResult(Map<String, dynamic> message) {
  final aiAnalysis = message['ai_analysis'] as List<dynamic>? ?? [];
  
  return Column(
    children: aiAnalysis.map((item) {
      return NutritionResultTable(
        foodName: item['item_name'] ?? 'Món ăn',
        confidence: (item['confidence_score'] ?? 0.0) / 100,
        nutrients: _formatNutrientsForTable(item['nutrients']),
        onApprove: () => _acceptAiAnalysisFromChat([item]),
        onReject: () => _rejectAnalysis(message),
        isLoading: _isLoadingChatbot,
      );
    }).toList(),
  );
}
```

### ✅ 3. Thêm Water Tracking Vào Nutrition Table

**Vấn đề:** Bảng dinh dưỡng không hiển thị lượng nước

**Giải pháp:**
- Thêm WATER vào macro configuration trong `NutritionResultTable`
- Hiển thị 5 chỉ số chính: **Calories, Protein, Carbs, Fat, Water**
- Water được hiển thị cùng hàng với 4 macros

**Files thay đổi:**
- `lib/widgets/nutrition_result_table.dart`:

```dart
final macroConfig = {
  'ENERC_KCAL': {'label': 'Calories', 'unit': 'kcal', 'color': ...},
  'PROCNT': {'label': 'Protein', 'unit': 'g', 'color': ...},
  'CHOCDF': {'label': 'Carbs', 'unit': 'g', 'color': ...},
  'FAT': {'label': 'Fat', 'unit': 'g', 'color': ...},
  'WATER': {'label': 'Water', 'unit': 'ml', 'color': const Color(0xFF4FC3F7)}, // ← MỚI
};
```

### ✅ 4. Đảm Bảo Chỉ 21 Nutrients Được Trả Về

**Hiện trạng:** ChatbotAPI (`main.py`) đã có prompt chính xác

Backend API `/analyze-nutrition` trong `ChatbotAPI/main.py` đã được cấu hình đúng để chỉ trả về 21 nutrients thiết yếu:

**21 Nutrients Thiết Yếu:**
```python
# MACRONUTRIENTS (4)
- ENERC_KCAL: Calories (kcal)
- PROCNT: Protein (g)
- CHOCDF: Total Carbohydrate (g)
- FAT: Total Fat (g)

# WATER (1)
- WATER: Water content (ml)

# VITAMINS (6)
- VITD: Vitamin D (IU)
- VITC: Vitamin C (mg)
- VITB12: Vitamin B12 (µg)
- VITA: Vitamin A (µg)
- VITE: Vitamin E (mg)
- VITK: Vitamin K (µg)

# MINERALS (6)
- MIN_CA: Calcium (mg)
- MIN_P: Phosphorus (mg)
- MIN_MG: Magnesium (mg)
- MIN_K: Potassium (mg)
- MIN_NA: Sodium (mg)
- MIN_FE: Iron (mg)

# FAT (1)
- TOTAL_FAT: Tổng chất béo (g)

# FIBER (1)
- FIBTG: Total Fiber (g)
```

### ✅ 5. Cập Nhật Progress Bars Sau Khi User Chấp Nhận

**Infrastructure đã có:**
- ✅ `Water_Intake` table với triggers tự động
- ✅ `DailySummary` table cho macros (calories, protein, fat, carbs)
- ✅ `UserNutrientManualLog` table cho vitamins và minerals
- ✅ Triggers tự động cập nhật khi AI meal được accept

**Luồng hoạt động:**

```mermaid
User nhấn "Chấp nhận" 
  ↓
ChatbotController.approveNutrition() 
  ↓
ManualNutritionService.saveManualIntake()
  ↓
Lưu vào UserNutrientManualLog + DailySummary
  ↓
Trigger tự động cập nhật Water_Intake (nếu có water)
  ↓
Trả về today_totals cho Flutter
  ↓
ProfileProvider.applyTodayTotals() cập nhật UI
  ↓
Progress bars tự động cập nhật
```

**Files liên quan:**
- `backend/controllers/chatController.js`: `approveNutrition()`
- `backend/services/manualNutritionService.js`: `saveManualIntake()`
- `backend/migrations/2025_water_intake_tracking.sql`: Triggers
- `lib/widgets/profile_provider.dart`: `applyTodayTotals()`

## 📊 Cấu Trúc Dữ Liệu

### Nutrition Data Format trong ChatbotMessage

```json
{
  "message_id": 123,
  "sender": "bot",
  "message_text": "Tôi đã phân tích món...",
  "nutrition_data": {
    "food_name": "Hamburger Combo",
    "confidence": 0.95,
    "nutrients": [
      {"nutrient_code": "ENERC_KCAL", "nutrient_name": "Calories", "amount": 450, "unit": "kcal"},
      {"nutrient_code": "PROCNT", "nutrient_name": "Protein", "amount": 0, "unit": "g"},
      {"nutrient_code": "FAT", "nutrient_name": "Total Fat", "amount": 0, "unit": "g"},
      {"nutrient_code": "CHOCDF", "nutrient_name": "Total Carbohydrate", "amount": 0, "unit": "g"},
      {"nutrient_code": "WATER", "nutrient_name": "Water", "amount": 350, "unit": "ml"}
      // ... 16 nutrients khác
    ]
  },
  "is_approved": null
}
```

### AI Analysis Data Format

```json
{
  "ai_analysis": [
    {
      "id": 456,
      "item_name": "Hamburger Combo",
      "item_type": "food",
      "confidence_score": 95.0,
      "water_ml": 350,
      "nutrients": {
        "enerc_kcal": 450,
        "procnt": 0,
        "fat": 0,
        "chocdf": 0,
        "water": 350,
        "vitc": 0,
        "min_ca": 0
        // ... total 21 fields
      }
    }
  ]
}
```

## 🗄️ Database Schema Liên Quan

### ChatbotMessage Table
```sql
CREATE TABLE ChatbotMessage (
    message_id SERIAL PRIMARY KEY,
    conversation_id INT REFERENCES ChatbotConversation(conversation_id),
    sender VARCHAR(20) CHECK (sender IN ('user', 'bot')),
    message_text TEXT,
    image_url TEXT,
    nutrition_data JSONB,  -- ← Lưu phân tích dinh dưỡng
    is_approved BOOLEAN,   -- ← NULL/TRUE/FALSE
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Water_Intake Table
```sql
CREATE TABLE Water_Intake (
    intake_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id),
    date DATE NOT NULL,
    today_water_ml NUMERIC(10,2) DEFAULT 0,
    from_drinks_ml NUMERIC(10,2) DEFAULT 0,
    from_ai_analysis_ml NUMERIC(10,2) DEFAULT 0,  -- ← Từ AI phân tích
    target_water_ml NUMERIC(10,2) DEFAULT 2000,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);
```

## 🔄 Testing Checklist

### Frontend Testing
- [x] Hình ảnh hiển thị đúng trong chatbot (cả local & network)
- [x] Nutrition table hiển thị với 5 macro chips (Calories, Protein, Carbs, Fat, Water)
- [x] Chi tiết nutrients hiển thị đầy đủ trong bảng
- [x] Nút Chấp nhận/Từ chối hoạt động
- [ ] **TODO:** Test progress bars cập nhật sau khi chấp nhận

### Backend Testing
- [x] `/chat/chatbot/conversation/:id/analyze-image` trả về nutrition_data đúng format
- [x] `/chat/chatbot/message/:id/approve` lưu nutrients vào DB
- [x] ManualNutritionService xử lý đúng 21 nutrients
- [ ] **TODO:** Verify trigger cập nhật Water_Intake khi accept AI meal

### ChatbotAPI Testing
- [x] `/analyze-nutrition` endpoint trả về đúng 21 nutrients
- [x] Gemini Vision prompt đúng format
- [ ] **TODO:** Test với nhiều loại món ăn khác nhau

## 📝 Notes & Improvements

### Đã Hoàn Thành ✅
1. ✅ Fix hiển thị hình ảnh trong chatbot
2. ✅ Hiển thị nutrition table thay vì text
3. ✅ Thêm Water vào macro summary
4. ✅ Đảm bảo 21 nutrients được trả về
5. ✅ Infrastructure cho progress bar updates (DB triggers)

### Cần Test Thêm 🧪
1. ⏳ Test end-to-end flow: gửi ảnh → phân tích → chấp nhận → kiểm tra progress bars
2. ⏳ Verify Water_Intake được cập nhật chính xác
3. ⏳ Test với nhiều món ăn khác nhau (phở, cơm, bánh mì, nước uống)
4. ⏳ Test khi reject (không lưu vào DB)

### Có Thể Cải Thiện Sau 💡
1. Thêm animation khi nutrition table xuất hiện
2. Hiển thị % Daily Value cho vitamins/minerals
3. Thêm biểu đồ tròn cho macros
4. Lưu lịch sử AI analysis để xem lại
5. Hỗ trợ multiple images trong 1 message

## 🚀 Deployment Notes

### Migration Files Cần Chạy
1. `2025_chat_system.sql` - ✅ Đã có
2. `2025_water_intake_tracking.sql` - ✅ Đã có
3. `2025_ai_analyzed_meals.sql` - ✅ Đã có (nếu chưa)

### Environment Variables
```bash
CHATBOT_API_URL=http://localhost:8000  # ChatbotAPI URL
GEMINI_API_KEY=your_key_here           # Gemini Vision API
```

### Khởi Động Services
```bash
# Terminal 1: Backend
cd Project/backend
npm start

# Terminal 2: ChatbotAPI
cd ChatbotAPI
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
python main.py

# Terminal 3: Flutter
cd Project
flutter run
```

## 📞 API Endpoints Summary

### Chatbot Nutrition Analysis
- `GET /chat/chatbot/conversation` - Lấy/tạo conversation
- `GET /chat/chatbot/conversation/:id/messages` - Lấy tin nhắn
- `POST /chat/chatbot/conversation/:id/message` - Gửi text
- `POST /chat/chatbot/conversation/:id/analyze-image` - Gửi ảnh phân tích
- `POST /chat/chatbot/message/:id/approve` - Chấp nhận/từ chối nutrition

### ChatbotAPI
- `POST /analyze-nutrition` - Phân tích dinh dưỡng từ hình ảnh
- `POST /chat` - Chat với AI chatbot

---

**Tác giả:** AI Assistant  
**Ngày:** December 10, 2025  
**Version:** 1.0.0
