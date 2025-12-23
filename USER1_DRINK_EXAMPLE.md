# Demo: User ID 1 - Drink Recommendations Example

## User Profile
**User ID:** 1  
**Health Conditions:** 
1. Type 2 Diabetes (condition_id: 1)
2. Obesity (condition_id: 4)
3. Gout (condition_id: 5)
4. Cholera (condition_id: 20)

---

## 🚫 DRINKS TO AVOID (7 drinks)

### HIGH Severity (10 restrictions):
| Drink | Reason | Condition |
|-------|--------|-----------|
| **Vietnamese Black Coffee** | Caffeine triggers acid reflux | Obesity |
| **Vietnamese Black Coffee** | Caffeine increases uric acid | Gout |
| **Vietnamese Black Coffee** | Affects blood sugar | Diabetes (medium) |
| **Vietnamese Milk Coffee** | High sugar and milk | Diabetes |
| **Vietnamese Milk Coffee** | Caffeine increases uric acid | Gout |
| **Vietnamese Milk Coffee** | Sugar may cause bloating | Cholera (medium) |
| **Iced Milk Coffee** | High sugar and milk | Diabetes |
| **Iced Milk Coffee** | Sugar may cause bloating | Cholera (medium) |
| **Bubble Milk Tea** | Very high calories | Obesity |
| **Bubble Milk Tea** | High sugar from brown sugar | Diabetes |
| **Sugarcane Juice** | Natural sugar very high | Diabetes |
| **Fresh Orange Juice** | Acidic, triggers reflux | Obesity |
| **Lemon Tea** | Acidic, stomach irritation | Obesity |

### Visual in UI:
```
❌ Vietnamese Black Coffee     ⚠️
   Opacity: 0.4 (dimmed)
   Icon: Red warning icon
   Subtitle: "Không khuyến khích - Có thể ảnh hưởng tình trạng sức khỏe"
   
   [User taps] → Warning Dialog appears:
   "Đồ uống 'Vietnamese Black Coffee' không được khuyến khích 
    dựa trên tình trạng sức khỏe của bạn.
    
    Bạn có chắc chắn muốn tiếp tục?"
    
    [Hủy] [Tiếp tục]
```

---

## ✅ DRINKS RECOMMENDED (10 drinks)

### HIGH Severity (11 recommendations):
| Drink | Benefit | Condition |
|-------|---------|-----------|
| **Coconut Water** | Flushes out uric acid | Gout |
| **Green Tea** | Antioxidants, improves insulin | Diabetes |
| **Pennywort Juice (2 types)** | Blood sugar control | Diabetes |
| **Pennywort Juice** | Low calorie herbal | Obesity |
| **Plain Water** | Reduces gout attacks | Gout |
| **Plain Water** | Best hydration | Diabetes |
| **Fresh Lemon Juice** | Vitamin C lowers uric acid | Gout |
| **Fresh Coconut Plus** | Electrolyte replacement | Cholera |
| **Fresh Coconut Plus** | Flushes uric acid | Gout |
| **Passion Fruit Juice** | Vitamin C reduces uric acid | Gout |

### MEDIUM Severity (3 recommendations):
| Drink | Benefit | Condition |
|-------|---------|-----------|
| **Ginger Honey Tea** | Improves insulin sensitivity | Diabetes |
| **Ginger Honey Tea** | Boosts metabolism | Obesity |
| **Mint Lime Tea** | Low calorie, refreshing | Obesity |

### Visual in UI:
```
✅ Coconut Water              ✓
   Background: Light green (Colors.green.shade50)
   Icon: Green check circle
   Text: Bold font
   Subtitle: "Khuyến khích - Tốt cho sức khỏe"
```

---

## 📊 Statistics

- **Total Drinks in Database:** 50
- **Drinks to Avoid for User 1:** 7
- **Drinks Recommended for User 1:** 10
- **Total Recommendations for User 1:** 27 (across 4 conditions)

---

## 💡 How It Works in Flutter UI

### When user opens Water Quick Add Sheet:

1. **Load Recommendations:**
```dart
final _drinkRecommendationService = UserDrinkRecommendationService();
await _drinkRecommendationService.loadUserDrinkRecommendations();

Set<int> _restrictedDrinkIds = {5, 6, 7, 59, 1, 2, 4}; // 7 drinks
Set<int> _recommendedDrinkIds = {3, 8, 19, 20, 23, 60, 61, 63, 65, 66}; // 10 drinks
```

2. **Render Drink List:**
```dart
ListView(
  children: drinks.map((drink) {
    final isRestricted = _restrictedDrinkIds.contains(drink.id);
    final isRecommended = _recommendedDrinkIds.contains(drink.id);
    
    return Opacity(
      opacity: isRestricted ? 0.4 : 1.0,
      child: ListTile(
        tileColor: isRecommended ? Colors.green.shade50 : null,
        trailing: isRestricted 
          ? Icon(Icons.warning, color: Colors.red)
          : isRecommended 
            ? Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }),
)
```

3. **Warning on Selection:**
```dart
onTap: () async {
  if (isRestricted) {
    final proceed = await _showRestrictionWarning(drink);
    if (!proceed) return; // User cancelled
  }
  // Add drink to log
  _logWater(drink);
}
```

---

## 🧪 Test Results

### API Endpoint Test:
```bash
GET /api/suggestions/user-drink-recommendations
Authorization: Bearer <user1_token>

Response:
{
  "success": true,
  "drinks_to_avoid": [
    {
      "drink_id": 5,
      "name": "Vietnamese Black Coffee",
      "vietnamese_name": "Cà Phê Đen",
      "reason": "Caffeine increases uric acid",
      "severity": "high",
      "condition_name": "Gout"
    },
    // ... 6 more drinks
  ],
  "drinks_to_recommend": [
    {
      "drink_id": 3,
      "name": "Coconut Water",
      "vietnamese_name": "Nước Dừa Tươi",
      "reason": "Flushes out uric acid",
      "severity": "high",
      "condition_name": "Gout"
    },
    // ... 9 more drinks
  ],
  "conditions": [
    {"condition_id": 1, "name_vi": "Tiểu đường type 2"},
    {"condition_id": 4, "name_vi": "Béo phì"},
    {"condition_id": 5, "name_vi": "Gout"},
    {"condition_id": 20, "name_vi": "Bệnh tả"}
  ]
}
```

---

## ✨ User Experience Flow

1. **User 1 opens My Diary app**
2. **Taps Water card → Taps "+" button**
3. **Water Quick Add Sheet appears**
4. **Sees drink list:**
   - ❌ Vietnamese Black Coffee (dimmed, red warning)
   - ❌ Bubble Milk Tea (dimmed, red warning)
   - ✅ Coconut Water (green background, check)
   - ✅ Green Tea (green background, check)
   - ✅ Plain Water (green background, check)
   
5. **User tries to select "Vietnamese Black Coffee"**
6. **Warning dialog appears:**
   ```
   ⚠️ Cảnh báo sức khỏe
   
   Đồ uống "Vietnamese Black Coffee" không được khuyến khích 
   dựa trên tình trạng sức khỏe của bạn:
   - Gout: Caffeine increases uric acid (HIGH)
   - Diabetes: Affects blood sugar (MEDIUM)
   - Obesity: Triggers acid reflux (HIGH)
   
   Bạn có chắc chắn muốn tiếp tục?
   
   [Hủy]  [Tiếp tục]
   ```

7. **User reconsiders and selects "Coconut Water" instead ✅**
8. **Drink logged successfully with 400ml**

---

## 🎯 Impact

**Before this feature:**
- User could add any drink without warnings
- No guidance based on health conditions
- Risk of consuming harmful drinks

**After this feature:**
- Clear visual feedback (opacity, colors, icons)
- Safety warnings before consuming restricted drinks
- Positive reinforcement for healthy choices
- User empowered to make informed decisions

---

**Date:** December 6, 2025  
**Database:** 50 drinks, 224 recommendations, 39 conditions (100% coverage)  
**User 1 Coverage:** 7 drinks to avoid, 10 drinks recommended
