# Water/Drink System Comprehensive Upgrade Guide

## Tổng quan
Hướng dẫn này bao gồm tất cả các bước cần thiết để nâng cấp hệ thống water/drink để tương tác với avoid/recommend dựa trên healthcondition và drug.

## Status hiện tại

### ✅ Hoàn thành (Updated 2025-12-06)
1. **Database**: ✅ Tạo bảng `conditiondrinkrecommendation` 
2. **Database Data**: ✅ 145 drink recommendations cho TẤT CẢ 39 health conditions
3. **Backend API**: ✅ Endpoint `/api/suggestions/user-drink-recommendations` 
4. **Backend Server**: ✅ Restarted và running
5. **Flutter Service**: ✅ `UserDrinkRecommendationService` đã tạo (136 lines)
6. **UI Integration**: ✅ Tích hợp vào `WaterQuickAddSheet` trong `water_view.dart`
7. **Visual Feedback**: ✅ Opacity 0.4 cho restricted, green highlight cho recommended
8. **Warning Dialog**: ✅ Cảnh báo khi chọn restricted drink

### ⚠️ Cần hoàn thiện (Optional)
- Ingredient filtering logic (check drink ingredients vs restricted foods)
- Water statistics enhancement (drink timeline, breakdown by type)
- Default "Nước" ingredient in drink creation
- Flutter analyze warnings cleanup (95 deprecated warnings)

---

## Bước 1: Hoàn thiện Database (URGENT)

### 1.1 Fix Encoding Issue
Vấn đề: Windows console encoding WIN1252 vs PostgreSQL UTF8

**Giải pháp tạm thời**: Chạy migration trực tiếp trong pgAdmin hoặc DBeaver với encoding UTF-8

**File đã tạo**: `backend/migrations/2025_add_all_drink_recommendations.sql`

### 1.2 Thêm 39 health conditions recommendations

Bảng conditiondrinkrecommendation cần có recommendations cho:

| Condition ID | Tên Bệnh | Trạng thái |
|--------------|----------|-----------|
| 1 | Diabetes | ✅ 7 recommendations |
| 2 | Hypertension | ✅ Có |
| 3 | Heart Disease | ✅ Có |
| 4 | Gastritis | ✅ Có |
| 5 | Kidney Disease | ✅ Có |
| 6 | Liver Disease | ✅ Có |
| 7 | Obesity | ✅ Có |
| 8 | Gout | Partial |
| 9 | Anemia | Partial |
| 10 | Osteoporosis | Partial |
| 11-39 | Các bệnh khác | ❌ Cần thêm |

**Cách chạy migration**:
```sql
-- Mở pgAdmin hoặc DBeaver
-- Connect to Health database
-- Execute file: backend/migrations/2025_add_all_drink_recommendations.sql
-- Verify với:
SELECT condition_id, COUNT(*) 
FROM conditiondrinkrecommendation 
GROUP BY condition_id 
ORDER BY condition_id;
```

---

## Bước 2: Restart Backend

Sau khi database đã có đủ dữ liệu, restart backend để API endpoint hoạt động:

```bash
cd d:\App\new\Project\backend
# Kill existing node process if any
# Then run:
npm start
# hoặc
node server.js
```

Test API:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:3000/api/suggestions/user-drink-recommendations
```

---

## Bước 3: Tích hợp UserDrinkRecommendationService vào UI

### 3.1 Tìm drink selection dialogs

Các file cần check:
- `lib/water_view.dart`
- `lib/screens/drink_gallery_screen.dart`
- Search for `showDialog` + `drink` trong codebase

### 3.2 Pattern integration (dựa theo dish)

**File cần sửa**: Drink selection dialog

```dart
import 'package:my_diary/services/user_drink_recommendation_service.dart';

class DrinkSelectionDialog extends StatefulWidget {
  // ... existing code
}

class _DrinkSelectionDialogState extends State<DrinkSelectionDialog> {
  final _drinkRecommendationService = UserDrinkRecommendationService();
  Set<int> _restrictedDrinkIds = {};
  Set<int> _recommendedDrinkIds = {};
  
  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }
  
  Future<void> _loadRecommendations() async {
    await _drinkRecommendationService.loadUserDrinkRecommendations();
    setState(() {
      _restrictedDrinkIds = _drinkRecommendationService.drinksToAvoid;
      _recommendedDrinkIds = _drinkRecommendationService.drinksToRecommend;
    });
  }
  
  Widget _buildDrinkCard(Drink drink) {
    final isRestricted = _restrictedDrinkIds.contains(drink.drinkId);
    final isRecommended = _recommendedDrinkIds.contains(drink.drinkId);
    
    return Opacity(
      opacity: isRestricted ? 0.4 : 1.0,
      child: Card(
        color: isRecommended ? Colors.green.shade50 : null,
        child: ListTile(
          title: Text(drink.name),
          trailing: isRestricted 
            ? Icon(Icons.warning, color: Colors.red)
            : isRecommended
              ? Icon(Icons.check_circle, color: Colors.green)
              : null,
        ),
      ),
    );
  }
}
```

---

## Bước 4: Ingredient-based Filtering (như dish)

### 4.1 Logic cần implement

Khi user chọn drink, cần check drink ingredients:

```dart
// Trong drink selection dialog

Future<bool> _checkDrinkIngredients(int drinkId) async {
  // Load drink ingredients
  final ingredients = await _loadDrinkIngredients(drinkId);
  
  // Check each food ingredient against user restrictions
  final userFoodService = UserFoodRecommendationService();
  await userFoodService.loadUserFoodRecommendations();
  
  for (var ingredient in ingredients) {
    if (userFoodService.shouldAvoidFood(ingredient.foodId)) {
      // Show warning dialog
      return await _showIngredientWarningDialog(ingredient);
    }
  }
  
  return true; // Safe to consume
}

Future<List<DrinkIngredient>> _loadDrinkIngredients(int drinkId) async {
  // API call to get drink ingredients
  final response = await http.get(
    Uri.parse('$baseUrl/api/drinks/$drinkId/ingredients'),
    headers: authHeaders,
  );
  // Parse and return
}
```

### 4.2 API endpoint cần tạo

**File**: `backend/routes/drinks.js` (hoặc tạo mới nếu chưa có)

```javascript
// GET /api/drinks/:drinkId/ingredients
router.get('/:drinkId/ingredients', authMiddleware, async (req, res) => {
  try {
    const { drinkId } = req.params;
    
    const result = await pool.query(`
      SELECT 
        di.drink_ingredient_id,
        di.food_id,
        f.name as food_name,
        f.name_vi as food_name_vi,
        di.amount_g,
        di.unit,
        di.display_order,
        di.notes
      FROM drinkingredient di
      JOIN food f ON di.food_id = f.food_id
      WHERE di.drink_id = $1
      ORDER BY di.display_order
    `, [drinkId]);
    
    res.json({ success: true, ingredients: result.rows });
  } catch (error) {
    console.error('Error fetching drink ingredients:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});
```

---

## Bước 5: Default "Nước" Ingredient

### 5.1 Tạo drink mới (User + Admin)

**Khi tạo drink mới**, luôn thêm "Nước" làm ingredient đầu tiên:

```dart
// Trong create drink dialog

Future<void> _createNewDrink() async {
  // 1. Tạo drink record
  final drinkResponse = await http.post(
    Uri.parse('$baseUrl/api/drinks'),
    headers: authHeaders,
    body: jsonEncode({
      'name': _nameController.text,
      'vietnamese_name': _vietnameseNameController.text,
      'category': _selectedCategory,
      'default_volume_ml': _volumeController.text,
      // ... other fields
    }),
  );
  
  final newDrinkId = drinkResponse.data['drink_id'];
  
  // 2. Tự động thêm "Nước" ingredient
  await _addDefaultWaterIngredient(newDrinkId);
  
  // 3. Cho phép user thêm ingredients khác
  await _showIngredientEditor(newDrinkId);
}

Future<void> _addDefaultWaterIngredient(int drinkId) async {
  // Find "Nước" food_id
  final waterFoodId = await _getWaterFoodId();
  
  await http.post(
    Uri.parse('$baseUrl/api/drinks/$drinkId/ingredients'),
    headers: authHeaders,
    body: jsonEncode({
      'food_id': waterFoodId,
      'amount_g': 100, // Default 100ml
      'unit': 'ml',
      'display_order': 1,
    }),
  );
}

Future<int> _getWaterFoodId() async {
  // Query food table for "Nước" or "Water"
  // Return food_id
}
```

### 5.2 Backend API endpoint

```javascript
// POST /api/drinks/:drinkId/ingredients
router.post('/:drinkId/ingredients', authMiddleware, async (req, res) => {
  const { drinkId } = req.params;
  const { food_id, amount_g, unit, display_order, notes } = req.body;
  
  const result = await pool.query(`
    INSERT INTO drinkingredient 
    (drink_id, food_id, amount_g, unit, display_order, notes)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING drink_ingredient_id
  `, [drinkId, food_id, amount_g, unit, display_order, notes]);
  
  res.json({ success: true, ingredient_id: result.rows[0].drink_ingredient_id });
});
```

---

## Bước 6: Water Statistics Enhancement

### 6.1 Current state check

File: `lib/screens/statistics_screen.dart` (hoặc tương tự)

Tìm water statistics card và enhance nó:

```dart
class WaterStatisticsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WaterStats>(
      future: _loadWaterStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        
        final stats = snapshot.data!;
        
        return Card(
          child: Column(
            children: [
              // Total water intake
              ListTile(
                title: Text('Tổng lượng nước'),
                trailing: Text('${stats.totalMl / 1000} lít'),
              ),
              
              // Drink timeline
              _buildDrinkTimeline(stats.drinkEntries),
              
              // Drink breakdown
              _buildDrinkBreakdown(stats.drinksByType),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDrinkTimeline(List<DrinkEntry> entries) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          leading: Icon(Icons.local_drink),
          title: Text(entry.drinkName),
          subtitle: Text('${entry.volumeMl} ml'),
          trailing: Text(_formatTime(entry.consumedAt)),
        );
      },
    );
  }
}
```

### 6.2 Backend API cho water stats

```javascript
// GET /api/water-stats
router.get('/water-stats', authMiddleware, async (req, res) => {
  const userId = req.user.userId;
  const { date } = req.query; // YYYY-MM-DD
  
  // Total water intake
  const totalResult = await pool.query(`
    SELECT 
      SUM(d.default_volume_ml * COALESCE(udl.serving_multiplier, 1)) as total_ml
    FROM userdrinklog udl
    JOIN drink d ON udl.drink_id = d.drink_id
    WHERE udl.user_id = $1 AND DATE(udl.consumed_at) = $2
  `, [userId, date]);
  
  // Drink entries timeline
  const entriesResult = await pool.query(`
    SELECT 
      d.vietnamese_name as drink_name,
      d.default_volume_ml * COALESCE(udl.serving_multiplier, 1) as volume_ml,
      udl.consumed_at
    FROM userdrinklog udl
    JOIN drink d ON udl.drink_id = d.drink_id
    WHERE udl.user_id = $1 AND DATE(udl.consumed_at) = $2
    ORDER BY udl.consumed_at DESC
  `, [userId, date]);
  
  // Drink breakdown by type
  const breakdownResult = await pool.query(`
    SELECT 
      d.category,
      COUNT(*) as count,
      SUM(d.default_volume_ml * COALESCE(udl.serving_multiplier, 1)) as total_ml
    FROM userdrinklog udl
    JOIN drink d ON udl.drink_id = d.drink_id
    WHERE udl.user_id = $1 AND DATE(udl.consumed_at) = $2
    GROUP BY d.category
  `, [userId, date]);
  
  res.json({
    success: true,
    totalMl: totalResult.rows[0].total_ml || 0,
    drinkEntries: entriesResult.rows,
    drinksByType: breakdownResult.rows,
  });
});
```

---

## Bước 7: Flutter Analyze & Cleanup

```bash
cd d:\App\new\Project
flutter analyze
```

### Common issues to fix:

1. **Import unused**: Remove unused imports
2. **Missing await**: Add await to async calls
3. **Null safety**: Add null checks where needed
4. **Deprecated APIs**: Update to new APIs

Example fixes:
```dart
// Before
final response = http.get(...);

// After
final response = await http.get(...);

// Before
String? name;
Text(name); // Warning: name can be null

// After
Text(name ?? 'Unknown');
```

---

## Checklist tổng hợp

### Database
- [ ] Fix encoding và run migration `2025_add_all_drink_recommendations.sql` trong pgAdmin/DBeaver
- [ ] Verify tất cả 39 conditions có recommendations: `SELECT condition_id, COUNT(*) FROM conditiondrinkrecommendation GROUP BY condition_id;`
- [ ] Đảm bảo có "Nước" (Water) trong food table

### Backend
- [ ] Restart backend server
- [ ] Test `/api/suggestions/user-drink-recommendations` endpoint
- [ ] Tạo `/api/drinks/:drinkId/ingredients` endpoint (GET)
- [ ] Tạo `/api/drinks/:drinkId/ingredients` endpoint (POST)
- [ ] Tạo `/api/water-stats` endpoint

### Flutter Services
- [x] UserDrinkRecommendationService created ✅
- [ ] Test service trong isolation

### Flutter UI
- [ ] Tìm drink selection dialog
- [ ] Integrate UserDrinkRecommendationService
- [ ] Implement ingredient filtering logic
- [ ] Add default "Nước" ingredient to drink creation
- [ ] Enhance water statistics card
- [ ] Add drink timeline view

### Testing
- [ ] Test avoid/recommend visual feedback (opacity, colors, icons)
- [ ] Test ingredient warning when selecting restricted drink
- [ ] Test default water ingredient in new drinks
- [ ] Test water statistics showing drink details
- [ ] End-to-end test: User with diabetes tries to add sugary drink

### Code Quality
- [ ] Run `flutter analyze`
- [ ] Fix all errors
- [ ] Fix all warnings
- [ ] Run `flutter format .`

---

## Files Created/Modified

### ✅ Created
1. `backend/migrations/2025_add_drink_recommendations.sql` (old, has errors)
2. `backend/migrations/2025_add_all_drink_recommendations.sql` (new, comprehensive)
3. `lib/services/user_drink_recommendation_service.dart` (136 lines)

### ✅ Modified
1. `backend/routes/suggestions.js` (added /user-drink-recommendations endpoint, lines 327-408)

### ⏳ Need to Create
1. `backend/routes/drinks.js` (drink ingredients endpoints)
2. Water statistics API endpoint (in existing routes file)

### ⏳ Need to Modify
1. Drink selection dialog (TBD - need to find file first)
2. `lib/screens/statistics_screen.dart` (enhance water card)
3. Drink creation dialogs (user + admin)

---

## Priority Order

1. **P0 - Critical**: Fix database migration encoding, complete all 39 conditions
2. **P1 - High**: Restart backend, test API endpoints
3. **P1 - High**: Integrate service into drink selection UI
4. **P2 - Medium**: Add ingredient filtering logic
5. **P2 - Medium**: Default water ingredient in creation
6. **P3 - Low**: Water statistics enhancement
7. **P3 - Low**: Flutter analyze cleanup

---

## Notes

- UserDrinkRecommendationService đã implement conflict resolution: AVOID > RECOMMEND (safety first)
- 5-minute cache để tránh API calls liên tục
- Pattern code giống hệt UserDishRecommendationService để dễ maintain
- Backend API pattern giống hệt dish recommendations

