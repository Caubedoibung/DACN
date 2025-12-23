# Daily Meal Suggestions - Complete Implementation Guide

## 📋 Overview

The **Daily Meal Suggestions** feature provides intelligent, personalized meal planning for users based on their nutritional needs, health conditions, and dietary preferences. The system generates optimized daily meal plans with Vietnamese specialty dishes and traditional drinks, using a sophisticated scoring algorithm to maximize nutrient gap filling.

**Implementation Date**: January 2025  
**Status**: ✅ Complete (Database + Backend + Frontend)

---

## 🎯 Key Features

### 1. Intelligent Meal Planning
- **Full-day planning**: Breakfast, Lunch, Dinner, and Snack
- **Health-conscious**: Max 2 dishes AND 2 drinks per meal (enforced by database trigger)
- **Nutrient optimization**: Fills daily nutrient gaps based on RDA targets
- **Smart scoring**: 0-100 score per item based on nutrient gap contribution
- **Contraindication filtering**: Excludes items conflicting with user health conditions

### 2. Vietnamese Food Database
- **60 Ingredients**: Quinoa, Chia seeds, exotic fruits, Vietnamese specialties
- **30 Dishes**: 
  - 10 Miền Trung specialties (Bún Bò Huế, Mì Quảng, etc.)
  - 8 Chay (Vegetarian) dishes
  - 7 Healthy dishes
  - 5 Hầm (Stew) dishes
- **20 Drinks**:
  - 6 Traditional Vietnamese drinks
  - 5 Herbal teas
  - 5 Detox drinks
  - 4 Health drinks
- **58 Nutrients per item**: Macros, vitamins, minerals, amino acids, fatty acids

### 3. User Workflow
```
1. User opens "Gợi Ý Ngày" tab
2. Select date (yesterday/today/tomorrow)
3. Click "Tạo gợi ý mới" → Opens meal count selection dialog
4. Choose dish/drink counts for each meal (max 2 each)
5. System generates suggestions (POST /api/suggestions/daily-meals)
6. View suggestions grouped by meal type (Breakfast/Lunch/Dinner/Snack)
7. Accept/Reject individual suggestions
   - Accept → Mark as accepted (green border) → Add to meal diary
   - Reject → Generate new replacement suggestion
8. Accepted suggestions show yellow border in Add Meal/Drink dialogs
```

---

## 🗄️ Database Schema

### Tables Created

#### 1. `user_daily_meal_suggestions`
Main table storing generated suggestions for each user.

```sql
CREATE TABLE user_daily_meal_suggestions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    dish_id INTEGER REFERENCES dish(id) ON DELETE SET NULL,
    drink_id INTEGER REFERENCES drink(id) ON DELETE SET NULL,
    portion_size DECIMAL(5,2) NOT NULL DEFAULT 1.0,
    score DECIMAL(5,2) NOT NULL DEFAULT 0.0,
    is_accepted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_dish_or_drink CHECK ((dish_id IS NOT NULL AND drink_id IS NULL) OR (dish_id IS NULL AND drink_id IS NOT NULL)),
    CONSTRAINT chk_valid_meal_type CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    CONSTRAINT chk_portion_positive CHECK (portion_size > 0),
    CONSTRAINT chk_score_range CHECK (score >= 0 AND score <= 100)
);
```

**Indexes**:
- `idx_user_daily_meal_date`: `(user_id, date)` - Fast date-based queries
- `idx_user_daily_meal_type`: `(user_id, meal_type)` - Filter by meal type
- `idx_user_daily_meal_accepted`: `(user_id, is_accepted)` - Find accepted suggestions
- `idx_user_daily_meal_created`: `(created_at)` - Cleanup by age

**Triggers**:
- `update_user_daily_meal_suggestions_timestamp`: Auto-update `updated_at` on changes
- `trg_validate_meal_item_limit`: Enforce max 2 dishes AND 2 drinks per meal

**Functions**:
- `cleanup_old_suggestions()`: Delete suggestions older than 7 days
- `cleanup_passed_meal_suggestions()`: Delete suggestions for past meals (not accepted)

#### 2. `usersetting` Extensions
Added 8 columns to store user preferences for meal item counts.

```sql
ALTER TABLE usersetting ADD COLUMN IF NOT EXISTS
    breakfast_dish_count INTEGER DEFAULT 1 CHECK (breakfast_dish_count BETWEEN 0 AND 2),
    breakfast_drink_count INTEGER DEFAULT 1 CHECK (breakfast_drink_count BETWEEN 0 AND 2),
    lunch_dish_count INTEGER DEFAULT 1 CHECK (lunch_dish_count BETWEEN 0 AND 2),
    lunch_drink_count INTEGER DEFAULT 1 CHECK (lunch_drink_count BETWEEN 0 AND 2),
    dinner_dish_count INTEGER DEFAULT 1 CHECK (dinner_dish_count BETWEEN 0 AND 2),
    dinner_drink_count INTEGER DEFAULT 1 CHECK (dinner_drink_count BETWEEN 0 AND 2),
    snack_dish_count INTEGER DEFAULT 1 CHECK (snack_dish_count BETWEEN 0 AND 2),
    snack_drink_count INTEGER DEFAULT 0 CHECK (snack_drink_count BETWEEN 0 AND 2);
```

**Trigger**: `trg_validate_meal_counts` - Ensures total meal counts don't exceed 2

---

## 🔧 Backend API

### Base URL
```
/api/suggestions/daily-meals
```

### Endpoints

#### 1. Generate Suggestions
**POST** `/api/suggestions/daily-meals`

Generate daily meal suggestions for a specific date.

**Request Body**:
```json
{
  "date": "2025-01-23"
}
```

**Response** (201 Created):
```json
{
  "message": "Đã tạo gợi ý bữa ăn thành công cho ngày 2025-01-23",
  "data": {
    "date": "2025-01-23",
    "breakfast": [...],
    "lunch": [...],
    "dinner": [...],
    "snack": [...]
  }
}
```

**Algorithm Steps**:
1. Calculate RDA targets (Harris-Benedict BMR × activity multiplier)
2. Calculate daily nutrient gaps (RDA - consumed)
3. Distribute gaps by meal (Breakfast 25%, Lunch 35%, Dinner 30%, Snack 10%)
4. Fetch candidate items (exclude contraindications)
5. Score items (0-100 based on gap filling)
6. Select top items for each meal
7. Save to database

#### 2. Get Suggestions
**GET** `/api/suggestions/daily-meals?date=2025-01-23`

Retrieve suggestions for a specific date.

**Response** (200 OK):
```json
{
  "data": {
    "date": "2025-01-23",
    "breakfast": [
      {
        "id": 1,
        "meal_type": "breakfast",
        "dish_id": 10,
        "dish_name": "Bún Bò Huế Chay",
        "portion_size": 1.0,
        "score": 87.5,
        "is_accepted": false
      }
    ],
    "lunch": [...],
    "dinner": [...],
    "snack": [...]
  }
}
```

#### 3. Accept Suggestion
**PUT** `/api/suggestions/daily-meals/:id/accept`

Accept a suggestion (mark as chosen).

**Response** (200 OK):
```json
{
  "message": "Đã chấp nhận gợi ý",
  "data": {
    "id": 1,
    "is_accepted": true
  }
}
```

#### 4. Reject Suggestion
**PUT** `/api/suggestions/daily-meals/:id/reject`

Reject a suggestion and generate a new replacement.

**Response** (200 OK):
```json
{
  "message": "Đã tạo gợi ý mới thay thế"
}
```

**Logic**: 
- Mark old suggestion as rejected (DELETE)
- Generate new suggestion for same meal type
- Use same scoring algorithm
- Exclude previously rejected items

#### 5. Delete Suggestion
**DELETE** `/api/suggestions/daily-meals/:id`

Delete a specific suggestion.

**Response** (200 OK):
```json
{
  "message": "Đã xóa gợi ý"
}
```

#### 6. Get Statistics
**GET** `/api/suggestions/daily-meals/stats?startDate=2025-01-01&endDate=2025-01-31`

Get suggestion statistics for a date range.

**Response** (200 OK):
```json
{
  "data": [
    {
      "date": "2025-01-23",
      "total_suggestions": 8,
      "accepted_suggestions": 5,
      "acceptance_rate": 62.5
    }
  ]
}
```

#### 7. Cleanup Old Suggestions
**POST** `/api/suggestions/daily-meals/cleanup`

Delete suggestions older than 7 days.

#### 8. Cleanup Passed Meals
**POST** `/api/suggestions/daily-meals/cleanup-passed`

Delete unaccepted suggestions for past meals.

**Should be called**: On app launch, daily cron job

---

## 📱 Flutter Frontend

### File Structure
```
lib/
├── models/
│   └── daily_meal_suggestion.dart      (240 lines)
├── services/
│   └── daily_meal_suggestion_service.dart  (260 lines)
├── widgets/
│   ├── daily_meal_suggestion_tab.dart   (450 lines)
│   ├── suggestion_card.dart             (200 lines)
│   └── meal_selection_dialog.dart       (240 lines)
└── screens/
    └── smart_suggestions_screen.dart    (Updated - added tab)
```

### Key Components

#### 1. Models (`daily_meal_suggestion.dart`)

**DailyMealSuggestion** - Main model class
```dart
class DailyMealSuggestion {
  final int id;
  final int userId;
  final DateTime date;
  final String mealType;
  final int? dishId;
  final String? dishName;
  final int? drinkId;
  final String? drinkName;
  final double portionSize;
  final double score;
  final bool isAccepted;
  
  // Helper methods
  String get displayName;
  IconData get icon;
  Color getScoreColor();
}
```

**DailyMealSuggestions** - Grouped by meal type
```dart
class DailyMealSuggestions {
  final DateTime date;
  final List<DailyMealSuggestion> breakfast;
  final List<DailyMealSuggestion> lunch;
  final List<DailyMealSuggestion> dinner;
  final List<DailyMealSuggestion> snack;
  
  bool get isEmpty;
  int get totalCount;
}
```

**SuggestionStats** - Analytics
```dart
class SuggestionStats {
  final DateTime date;
  final int totalSuggestions;
  final int acceptedSuggestions;
  final int rejectedSuggestions;
  
  double get acceptanceRate;
  double get rejectionRate;
}
```

#### 2. Service Layer (`daily_meal_suggestion_service.dart`)

```dart
class DailyMealSuggestionService {
  static Future<Map<String, dynamic>> generateSuggestions({DateTime? date});
  static Future<Map<String, dynamic>> getSuggestions({DateTime? date});
  static Future<Map<String, dynamic>> acceptSuggestion(int suggestionId);
  static Future<Map<String, dynamic>> rejectSuggestion(int suggestionId);
  static Future<Map<String, dynamic>> deleteSuggestion(int suggestionId);
  static Future<Map<String, dynamic>> getStats({DateTime? startDate, DateTime? endDate});
  static Future<Map<String, dynamic>> cleanupPassedMeals();
}
```

#### 3. UI Components

**DailyMealSuggestionTab** - Main tab view
- Date navigation (previous/next day, date picker)
- Grouped suggestions by meal type
- Empty state when no suggestions
- Pull-to-refresh
- FAB to generate new suggestions

**SuggestionCard** - Individual suggestion card
- Item name + type badge (Món ăn/Đồ uống)
- Score display with color coding (Red < 60, Orange 60-79, Green ≥ 80)
- Portion size
- Accept/Reject buttons
- Accepted state banner (green border + message)

**MealSelectionDialog** - Meal count picker
- 4 meal sections (Breakfast/Lunch/Dinner/Snack)
- Dish/drink counters with +/- buttons
- Max 2 constraint enforcement (buttons disabled at 2)
- Confirm/Cancel actions

### UI Flow
```
Smart Suggestions Screen (TabBar)
├── Tab 1: Gợi Ý Món (Original Smart Suggestions)
│   └── Context + Filters + Carousel
└── Tab 2: Gợi Ý Ngày (Daily Meal Suggestions)
    ├── Date Header (← Today →)
    ├── Meal Sections
    │   ├── Bữa sáng (2 cards)
    │   ├── Bữa trưa (2 cards)
    │   ├── Bữa tối (2 cards)
    │   └── Bữa phụ (1 card)
    └── FAB: Tạo gợi ý mới
```

---

## 🎨 UI/UX Design

### Color Scheme
- **Primary**: Orange (`Colors.orange`) - Energy, warmth, food-related
- **Accepted**: Green - Positive confirmation
- **Rejected**: Red - Negative action
- **Score Colors**:
  - 🔴 Red (< 60): Low score
  - 🟠 Orange (60-79): Medium score
  - 🟢 Green (≥ 80): High score

### Typography
- **Section Headers**: 18px, Bold, Black
- **Item Names**: 16px, Bold, Black
- **Descriptions**: 13px, Regular, Grey
- **Scores**: 14px, Bold, Score Color
- **Buttons**: 14px, Medium, White/Color

### Spacing
- Card padding: 12px
- Section spacing: 16px
- Button spacing: 12px horizontal
- Icon spacing: 8px

---

## 🔐 Security & Validation

### Authentication
- All API endpoints require JWT token (`authenticateToken` middleware)
- User ID extracted from token payload
- Ownership validation on all suggestion operations

### Data Validation
- **Meal counts**: 0-2 (database CHECK constraint)
- **Portion size**: > 0 (database CHECK constraint)
- **Score**: 0-100 (database CHECK constraint)
- **Meal type**: ENUM validation ('breakfast', 'lunch', 'dinner', 'snack')
- **Item limit**: Max 2 dishes AND 2 drinks per meal (database trigger)

### Error Handling
- Vietnamese error messages for all operations
- Graceful degradation on API failures
- User-friendly error display in UI
- Retry mechanisms in Flutter service

---

## 📊 Algorithm Details

### 1. RDA Calculation
```javascript
BMR (Male) = 88.362 + (13.397 × weight_kg) + (4.799 × height_cm) - (5.677 × age)
BMR (Female) = 447.593 + (9.247 × weight_kg) + (3.098 × height_cm) - (4.330 × age)

TDEE = BMR × Activity Multiplier
- Sedentary: 1.2
- Light: 1.375
- Moderate: 1.55
- Active: 1.725
- Very Active: 1.9

RDA Targets = Standard RDA × (TDEE / 2000)
```

### 2. Nutrient Gap Distribution
```javascript
Daily Gap = RDA Target - Already Consumed

Meal Gaps:
- Breakfast: Daily Gap × 25%
- Lunch: Daily Gap × 35%
- Dinner: Daily Gap × 30%
- Snack: Daily Gap × 10%
```

### 3. Scoring Algorithm
```javascript
For each nutrient:
  contribution = item_nutrient / gap_for_meal
  contribution_capped = min(contribution, 1.5)  // Cap at 150%
  
weighted_score = Σ (contribution_capped × weight × 100) / Σ weights

Final Score = min(weighted_score, 100)

Nutrient Weights:
- Calories: 2.0
- Protein: 2.5
- Fat: 1.5
- Carbohydrates: 2.0
- Vitamins: 1.2-2.0
- Minerals: 1.0-2.0
- Others: 0.8-1.5
```

---

## 🧪 Testing Checklist

### Database Tests
- [ ] Max 2 constraint enforcement (trigger fires on 3rd item)
- [ ] Cleanup functions run correctly
- [ ] Timestamps auto-update
- [ ] Cascade deletes work properly

### Backend Tests
- [ ] Generate suggestions with different health conditions
- [ ] Accept/reject flow updates database correctly
- [ ] Stats calculation accurate
- [ ] Cleanup endpoints delete correct records
- [ ] Scoring algorithm produces 0-100 range

### Frontend Tests
- [ ] Tab navigation works
- [ ] Date picker updates suggestions
- [ ] Accept/reject buttons update UI
- [ ] Loading states display correctly
- [ ] Empty states show helpful messages
- [ ] Meal selection dialog enforces max 2
- [ ] Pull-to-refresh reloads data

### Integration Tests
- [ ] End-to-end: Generate → View → Accept → Add to Diary
- [ ] Yellow border appears in Add Meal dialog for accepted dishes
- [ ] Yellow border appears in Add Drink dialog for accepted drinks
- [ ] Cleanup on app launch removes passed meals

---

## 📝 Migration Files

### Order of Execution
1. `2025_daily_meal_suggestions_table.sql` - Main table
2. `2025_usersetting_meal_counts.sql` - User preferences
3. `2025_food_ingredients_vietnam_extended.sql` - 60 ingredients
4. `2025_dishes_vietnam_specialty.sql` - 30 dishes
5. `2025_drinks_vietnam_traditional.sql` - 20 drinks
6. `2025_dishnutrient_vietnam_specialty.sql` - First 3 dishes nutrients
7. `2025_dishnutrient_part2.sql` - Remaining 27 dishes nutrients
8. `2025_drinknutrient_vietnam_traditional.sql` - All 20 drinks nutrients

**Total**: 8 files, 1809 lines SQL, 2900 nutrient records

---

## 🚀 Deployment Steps

### 1. Database Migration
```bash
# Connect to PostgreSQL
psql -U your_user -d your_database

# Run migrations in order
\i database_migrations/2025_daily_meal_suggestions_table.sql
\i database_migrations/2025_usersetting_meal_counts.sql
\i database_migrations/2025_food_ingredients_vietnam_extended.sql
\i database_migrations/2025_dishes_vietnam_specialty.sql
\i database_migrations/2025_drinks_vietnam_traditional.sql
\i database_migrations/2025_dishnutrient_vietnam_specialty.sql
\i database_migrations/2025_dishnutrient_part2.sql
\i database_migrations/2025_drinknutrient_vietnam_traditional.sql

# Verify
SELECT COUNT(*) FROM user_daily_meal_suggestions;
SELECT COUNT(*) FROM dish WHERE id >= 1000;
SELECT COUNT(*) FROM drink WHERE id >= 1000;
```

### 2. Backend Deployment
```bash
cd backend

# Install dependencies (if needed)
npm install

# Verify route registration in others/index.js
grep "dailyMealSuggestions" others/index.js

# Restart server
npm start
```

### 3. Flutter Build
```bash
cd Project

# Get dependencies
flutter pub get

# Verify imports
flutter analyze

# Build for testing
flutter run

# Production build
flutter build apk  # Android
flutter build ios  # iOS
```

### 4. Post-Deployment
- [ ] Test API endpoints with Postman/curl
- [ ] Verify Flutter app connects to backend
- [ ] Generate test suggestions
- [ ] Accept/reject test flow
- [ ] Check database records
- [ ] Monitor error logs

---

## 🐛 Troubleshooting

### Common Issues

#### 1. "Trigger prevents insertion" error
**Cause**: Trying to add more than 2 dishes or 2 drinks to a meal  
**Solution**: Check meal counts in request, ensure max 2 items

#### 2. "No suggestions found" in UI
**Cause**: Backend API not returning data  
**Solution**: 
- Check backend logs
- Verify database has dishes/drinks
- Check user authentication token
- Ensure date format is YYYY-MM-DD

#### 3. Score always shows 0
**Cause**: Nutrient data missing or gap calculation fails  
**Solution**:
- Verify dishnutrient/drinknutrient records exist
- Check user RDA settings
- Ensure daily meal logs exist for gap calculation

#### 4. Accept button doesn't work
**Cause**: API error or missing suggestion ID  
**Solution**:
- Check network logs in Flutter DevTools
- Verify suggestion ID in database
- Check authentication token validity

---

## 📚 References

### Backend Files
- `backend/services/dailyMealSuggestionService.js` (660 lines)
- `backend/controllers/dailyMealSuggestionController.js` (230 lines)
- `backend/routes/dailyMealSuggestions.js` (80 lines)
- `backend/others/index.js` (route registration)

### Frontend Files
- `lib/models/daily_meal_suggestion.dart` (240 lines)
- `lib/services/daily_meal_suggestion_service.dart` (260 lines)
- `lib/widgets/daily_meal_suggestion_tab.dart` (450 lines)
- `lib/widgets/suggestion_card.dart` (200 lines)
- `lib/widgets/meal_selection_dialog.dart` (240 lines)
- `lib/screens/smart_suggestions_screen.dart` (Updated)

### Database Files
- `database_migrations/2025_daily_meal_suggestions_table.sql` (150 lines)
- `database_migrations/2025_usersetting_meal_counts.sql` (120 lines)
- `database_migrations/2025_food_ingredients_vietnam_extended.sql` (150 lines)
- `database_migrations/2025_dishes_vietnam_specialty.sql` (80 lines)
- `database_migrations/2025_drinks_vietnam_traditional.sql` (75 lines)
- `database_migrations/2025_dishnutrient_vietnam_specialty.sql` (204 lines)
- `database_migrations/2025_dishnutrient_part2.sql` (450 lines)
- `database_migrations/2025_drinknutrient_vietnam_traditional.sql` (580 lines)

### Documentation
- `backend/README_DAILY_MEAL_API.md` - API documentation
- `database_migrations/README_DAILY_MEAL_SUGGESTIONS.md` - Database guide
- This file - Complete implementation guide

---

## ✅ Implementation Status

### Phase 1: Database ✅ COMPLETE
- [x] Main table with triggers
- [x] User preferences columns
- [x] 60 ingredients
- [x] 30 dishes
- [x] 20 drinks
- [x] 2900 nutrient records

### Phase 2: Backend ✅ COMPLETE
- [x] Service layer with algorithm
- [x] Controller with 8 endpoints
- [x] Route registration
- [x] Vietnamese error messages

### Phase 3: Frontend ✅ COMPLETE
- [x] Model classes
- [x] Service layer
- [x] UI components (tab, cards, dialogs)
- [x] Tab integration in Smart Suggestions screen

### Phase 4: Integration ⏳ PENDING
- [ ] Yellow border in Add Meal dialog
- [ ] Yellow border in Add Drink dialog
- [ ] Cleanup on app launch

### Phase 5: Testing ⏳ PENDING
- [ ] Unit tests
- [ ] Integration tests
- [ ] User acceptance testing

---

## 🎓 Learning Outcomes

This implementation demonstrates:
- **Database Design**: Triggers, constraints, indexes, cleanup functions
- **Algorithm Development**: Scoring, gap-filling, optimization
- **RESTful API**: 8 endpoints with proper HTTP methods
- **Flutter State Management**: StatefulWidget, async operations
- **UI/UX**: Multi-tab navigation, dialogs, cards, empty states
- **Security**: JWT authentication, ownership validation
- **Data Modeling**: Complex relationships (dishes, drinks, nutrients)
- **Vietnamese Localization**: All UI text in Vietnamese

---

## 📞 Support

For questions or issues:
1. Check this documentation
2. Review backend logs
3. Check database triggers/constraints
4. Verify Flutter console output
5. Test API endpoints independently

**Last Updated**: January 23, 2025  
**Version**: 1.0.0
