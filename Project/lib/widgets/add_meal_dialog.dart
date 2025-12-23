import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/screens/ai_image_analysis_screen.dart';
import '../services/dish_service.dart';
import '../services/meal_service.dart';
import '../services/food_service.dart';
import '../services/user_food_recommendation_service.dart';
import '../services/user_dish_recommendation_service.dart';
import '../services/smart_suggestion_service.dart';
import '../l10n/app_localizations.dart';
import 'package:my_diary/ui_view/vitamin_view.dart';
import 'package:my_diary/ui_view/mineral_view.dart';
import '../config/api_config.dart';

class AddMealDialog extends StatefulWidget {
  final String mealType; // breakfast, lunch, snack, dinner

  const AddMealDialog({super.key, required this.mealType});

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _weightController = TextEditingController(
    text: '100',
  );

  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedFood;
  Map<String, dynamic>? _detailedNutrition; // Full nutrition from API
  List<Map<String, dynamic>> _portionSuggestions =
      []; // Portion size suggestions
  List<Map<String, dynamic>> _quickAddSuggestions =
      []; // Frequently eaten foods
  Set<int> _restrictedFoodIds = {};
  Set<int> _recommendedFoodIds = {};
  Set<int> _restrictedDishIds = {};
  Set<int> _recommendedDishIds = {};
  Set<int> _pinnedFoodIds = {}; // NEW: Pinned food IDs
  Set<int> _pinnedDishIds = {}; // NEW: Pinned dish IDs
  Set<int> _pinnedDrinkIds = {}; // NEW: Pinned drink IDs
  Set<int> _pinnedIngredientFoodIds =
      {}; // NEW: Food IDs from pinned dish/drink ingredients
  bool _isSearching = false;
  bool _isSubmitting = false;
  bool _loadingNutrition = false;
  bool _showQuickAdd = true; // Show quick add initially
  String _searchType = 'food'; // 'food' or 'dish'

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Load quick add suggestions
    _loadQuickAddSuggestions();

    // Load initial foods list
    _loadInitialFoods();

    // Load restricted foods for the user so UI can disable them
    _loadRestrictedFoods();

    // Load pinned suggestions
    _loadPinnedSuggestions();

    // Auto-search when user types
    _searchController.addListener(() {
      if (_searchController.text.length >= 2) {
        setState(() {
          _showQuickAdd = false;
        });
        _searchFoods(_searchController.text);
      } else if (_searchController.text.isEmpty) {
        setState(() {
          _searchResults = [];
          _showQuickAdd = true;
        });
        // Reload foods when search is cleared
        if (_searchType == 'food') {
          _loadInitialFoods();
        }
      }
    });

    // Reload nutrition when weight changes
    _weightController.addListener(() {
      if (_selectedFood != null) {
        if (_searchType == 'dish') {
          _loadDishNutrition();
        } else {
          final foodId = _selectedFood!['food_id'];
          final weight = double.tryParse(_weightController.text);
          if (foodId != null && weight != null && weight > 0) {
            _loadDetailedNutrition(foodId, weight);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _weightController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialFoods() async {
    if (_searchType != 'food') return;

    setState(() => _isSearching = true);
    try {
      final results = await FoodService.searchFoods('', limit: 50);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error loading foods: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _loadInitialDishes() async {
    if (_searchType != 'dish') return;

    setState(() => _isSearching = true);
    try {
      // Load all dishes (public + user's own)
      final results = await DishService.getDishes();
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Mark dishes that contain restricted foods (runs async, updates state when ready)
      _markRestrictedDishes(results);
    } catch (e) {
      debugPrint('Error loading dishes: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      if (_searchType == 'dish') {
        // Search dishes
        final results = await DishService.getDishes(search: query);
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
        // Mark restricted dishes asynchronously
        _markRestrictedDishes(results);
      } else {
        // Search foods using FoodService
        final results = await FoodService.searchFoods(query, limit: 20);
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  /// For each dish in [dishes], attempt to fetch its ingredients and mark
  /// `dish['is_restricted'] = true` if any ingredient's food_id is in
  /// `_restrictedFoodIds`, and `dish['is_recommended'] = true` if all
  /// ingredients are recommended. This runs asynchronously and updates
  /// `_searchResults` when each dish is checked so the UI can show faded
  /// items like individual foods.
  Future<void> _markRestrictedDishes(List<Map<String, dynamic>> dishes) async {
    if (dishes.isEmpty) return;

    for (var i = 0; i < dishes.length; i++) {
      final dish = dishes[i];
      try {
        final dishId = dish['dish_id'] as int?;
        if (dishId == null) continue;

        // First, check if dish itself is directly restricted or recommended
        // (from conditiondishrecommendation table)
        if (_restrictedDishIds.contains(dishId)) {
          setState(() {
            final idx = _searchResults.indexWhere(
              (d) => d['dish_id'] == dishId,
            );
            if (idx != -1) {
              _searchResults[idx] =
                  Map<String, dynamic>.from(_searchResults[idx])
                    ..['is_restricted'] = true
                    ..['is_recommended'] = false;
            }
          });
          continue; // Skip ingredient check
        }

        if (_recommendedDishIds.contains(dishId)) {
          setState(() {
            final idx = _searchResults.indexWhere(
              (d) => d['dish_id'] == dishId,
            );
            if (idx != -1) {
              _searchResults[idx] =
                  Map<String, dynamic>.from(_searchResults[idx])
                    ..['is_restricted'] = false
                    ..['is_recommended'] = true;
            }
          });
          continue; // Skip ingredient check
        }

        // If the result already contains an ingredients array, use it first
        List<dynamic>? ingredients = dish['ingredients'] as List<dynamic>?;

        if (ingredients == null) {
          final details = await DishService.getDishDetails(dishId);
          if (details == null) continue;
          // Backend may wrap dish under 'data' or 'dish'
          final payload = details['data'] ?? details['dish'] ?? details;
          ingredients = List<dynamic>.from(payload['ingredients'] ?? []);
        }

        final blocked = ingredients.any((ing) {
          try {
            final fid = (ing is Map) ? (ing['food_id'] as int?) : null;
            return fid != null && _restrictedFoodIds.contains(fid);
          } catch (e) {
            return false;
          }
        });

        // Check if dish contains recommended foods
        final hasRecommended =
            ingredients.isNotEmpty &&
            ingredients.any((ing) {
              try {
                final fid = (ing is Map) ? (ing['food_id'] as int?) : null;
                return fid != null && _recommendedFoodIds.contains(fid);
              } catch (e) {
                return false;
              }
            });

        if (blocked) {
          // update the dish entry in _searchResults (preserve other fields)
          setState(() {
            final idx = _searchResults.indexWhere(
              (d) => d['dish_id'] == dishId,
            );
            if (idx != -1) {
              _searchResults[idx] =
                  Map<String, dynamic>.from(_searchResults[idx])
                    ..['is_restricted'] = true
                    ..['is_recommended'] = false;
            }
          });
        } else {
          // mark explicitly false to avoid null ambiguity
          setState(() {
            final idx = _searchResults.indexWhere(
              (d) => d['dish_id'] == dishId,
            );
            if (idx != -1) {
              _searchResults[idx] =
                  Map<String, dynamic>.from(_searchResults[idx])
                    ..['is_restricted'] = false
                    ..['is_recommended'] = hasRecommended;
            }
          });
        }
      } catch (e) {
        // ignore and continue
      }
    }
  }

  Future<void> _loadQuickAddSuggestions() async {
    try {
      final baseUrl = const String.fromEnvironment(
        'API_URL',
        defaultValue: ApiConfig.baseUrl,
      );

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse(
          '$baseUrl/meal-history/quick-add?limit=5&mealType=${widget.mealType}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _quickAddSuggestions = List<Map<String, dynamic>>.from(
            data['suggestions'] ?? [],
          );
        });
      }
    } catch (e) {
      // Ignore errors for quick add
    }
  }

  Future<void> _loadRestrictedFoods() async {
    try {
      final foodService = UserFoodRecommendationService();
      await foodService.loadUserFoodRecommendations();

      final dishService = UserDishRecommendationService();
      await dishService.loadUserDishRecommendations();

      setState(() {
        _restrictedFoodIds = foodService.foodsToAvoid;
        _recommendedFoodIds = foodService.foodsToRecommend;
        _restrictedDishIds = dishService.dishesToAvoid;
        _recommendedDishIds = dishService.dishesToRecommend;
      });

      debugPrint('🔴 Loaded food recommendations:');
      debugPrint(
        '   Restricted: ${_restrictedFoodIds.length} foods - ${_restrictedFoodIds.take(5).join(", ")}',
      );
      debugPrint(
        '   Recommended: ${_recommendedFoodIds.length} foods - ${_recommendedFoodIds.take(5).join(", ")}',
      );
      debugPrint('🍲 Loaded dish recommendations:');
      debugPrint(
        '   Restricted: ${_restrictedDishIds.length} dishes - ${_restrictedDishIds.take(5).join(", ")}',
      );
      debugPrint(
        '   Recommended: ${_recommendedDishIds.length} dishes - ${_recommendedDishIds.take(5).join(", ")}',
      );

      // If dishes are already loaded, re-evaluate them now that we know restricted ids
      if (_searchType == 'dish' && _searchResults.isNotEmpty) {
        _markRestrictedDishes(_searchResults);
      }
    } catch (e) {
      debugPrint('Error loading food/dish recommendations: $e');
    }
  }

  Future<void> _loadPinnedSuggestions() async {
    try {
      final result = await SmartSuggestionService.getPinnedSuggestions();

      if (result['error'] != null) {
        debugPrint('⚠️ Error loading pinned suggestions: ${result['error']}');
        return;
      }

      final pins = List<Map<String, dynamic>>.from(result['pins'] ?? []);

      final Set<int> pinnedFoods = {};
      final Set<int> pinnedDishes = {};
      final Set<int> pinnedDrinks = {};
      final Set<int> ingredientFoods = {};

      for (var pin in pins) {
        final itemType = pin['item_type'] as String?;
        final itemId = pin['item_id'] as int?;

        if (itemType == null || itemId == null) continue;

        if (itemType == 'dish') {
          pinnedDishes.add(itemId);
          // Load dish ingredients
          try {
            final dishDetails = await DishService.getDishDetails(itemId);
            if (dishDetails != null) {
              final payload =
                  dishDetails['data'] ?? dishDetails['dish'] ?? dishDetails;
              final ingredients = List<dynamic>.from(
                payload['ingredients'] ?? [],
              );
              for (var ing in ingredients) {
                final foodId = (ing is Map) ? (ing['food_id'] as int?) : null;
                if (foodId != null) {
                  ingredientFoods.add(foodId);
                }
              }
            }
          } catch (e) {
            debugPrint('Error loading dish $itemId ingredients: $e');
          }
        } else if (itemType == 'drink') {
          pinnedDrinks.add(itemId);
          // Load drink ingredients (if API exists)
          // For now, we'll skip drink ingredients as the API may not exist yet
        } else if (itemType == 'food') {
          pinnedFoods.add(itemId);
        }
      }

      setState(() {
        _pinnedFoodIds = pinnedFoods;
        _pinnedDishIds = pinnedDishes;
        _pinnedDrinkIds = pinnedDrinks;
        _pinnedIngredientFoodIds = ingredientFoods;
      });

      debugPrint('📌 Loaded pinned suggestions:');
      debugPrint('   Foods: ${_pinnedFoodIds.length} - $_pinnedFoodIds');
      debugPrint('   Dishes: ${_pinnedDishIds.length} - $_pinnedDishIds');
      debugPrint('   Drinks: ${_pinnedDrinkIds.length} - $_pinnedDrinkIds');
      debugPrint(
        '   Ingredient Foods: ${_pinnedIngredientFoodIds.length} - $_pinnedIngredientFoodIds',
      );
    } catch (e) {
      debugPrint('Error loading pinned suggestions: $e');
    }
  }

  Future<void> _loadPortionSuggestions(int foodId) async {
    try {
      final baseUrl = const String.fromEnvironment(
        'API_URL',
        defaultValue: ApiConfig.baseUrl,
      );

      final response = await http.get(Uri.parse('$baseUrl/portions/$foodId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _portionSuggestions = [
            ...List<Map<String, dynamic>>.from(data['food_specific'] ?? []),
            ...List<Map<String, dynamic>>.from(data['generic'] ?? []),
          ];

          // Add user average if available
          if (data['user_average'] != null) {
            _portionSuggestions.insert(0, data['user_average']);
          }
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _loadDetailedNutrition(int foodId, double weightG) async {
    setState(() {
      _loadingNutrition = true;
    });

    try {
      final baseUrl = const String.fromEnvironment(
        'API_URL',
        defaultValue: ApiConfig.baseUrl,
      );

      final response = await http.get(
        Uri.parse(
          '$baseUrl/portions/calculate/nutrition?foodId=$foodId&weightG=$weightG',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _detailedNutrition = data;
          _loadingNutrition = false;
        });
      } else {
        setState(() {
          _loadingNutrition = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingNutrition = false;
      });
    }
  }

  Future<void> _showFoodDetailDialog(Map<String, dynamic> food) async {
    final foodId = food['food_id'];
    if (foodId == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final baseUrl = const String.fromEnvironment(
        'API_URL',
        defaultValue: ApiConfig.baseUrl,
      );

      final response = await http.get(Uri.parse('$baseUrl/foods/$foodId'));

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foodData = data['food'];
        final nutrients = data['nutrients'] as List<dynamic>? ?? [];

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 600,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.nearlyBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: FitnessAppTheme.nearlyBlue.withValues(
                                  alpha: 0.2,
                                ),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child:
                                  foodData['image_url'] != null &&
                                      foodData['image_url']
                                          .toString()
                                          .isNotEmpty
                                  ? Image.network(
                                      foodData['image_url'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.restaurant,
                                            size: 32,
                                            color: FitnessAppTheme.grey,
                                          ),
                                    )
                                  : Icon(
                                      Icons.restaurant,
                                      size: 32,
                                      color: FitnessAppTheme.grey,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foodData['name'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                                if (foodData['category'] != null)
                                  Text(
                                    foodData['category'],
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontSize: 13,
                                      color: FitnessAppTheme.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Nutrition Facts (per 100g)',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: FitnessAppTheme.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: nutrients.isEmpty
                            ? Center(
                                child: Text(
                                  'No nutrition information available',
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontSize: 14,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: nutrients.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: FitnessAppTheme.grey.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  final nutrient = nutrients[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            nutrient['nutrient_name'] ?? '',
                                            style: const TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${((nutrient['amount_per_100g'] is String ? double.tryParse(nutrient['amount_per_100g']) : nutrient['amount_per_100g']) ?? 0).toStringAsFixed(2)} ${nutrient['unit'] ?? ''}',
                                          style: const TextStyle(
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(l10n.cannotLoadFoodInfo);
                },
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _selectFood(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
      if (_searchType == 'dish') {
        _searchController.text = food['vietnamese_name'] ?? food['name'] ?? '';
      } else {
        _searchController.text = food['name'] ?? '';
      }
      _searchResults = [];
    });

    // Load portion suggestions and detailed nutrition for foods only
    if (_searchType == 'food') {
      final foodId = food['food_id'];
      if (foodId != null) {
        _loadPortionSuggestions(foodId);
        final weight = double.tryParse(_weightController.text) ?? 100;
        _loadDetailedNutrition(foodId, weight);
      }
    } else {
      // For dishes, calculate nutrients using MealService
      _loadDishNutrition();
    }
  }

  Future<void> _loadDishNutrition() async {
    if (_selectedFood == null) return;

    final dishId = _selectedFood!['dish_id'];
    if (dishId == null) return;

    setState(() {
      _loadingNutrition = true;
    });

    try {
      final weight = double.tryParse(_weightController.text) ?? 100;

      // Get full nutrient details from dish
      final nutrients = await DishService.getDishNutrients(dishId);

      // Calculate scaled nutrients based on weight
      final scaledNutrients = <String, dynamic>{};
      final multiplier = weight / 100.0;

      for (final nutrient in nutrients) {
        final name = nutrient['nutrient_name'] as String?;
        final amountPer100g =
            (nutrient['amount_per_100g'] as num?)?.toDouble() ?? 0.0;
        final unit = nutrient['unit'] as String?;

        if (name != null) {
          scaledNutrients[name] = {
            'amount': amountPer100g * multiplier,
            'unit': unit ?? 'g',
          };
        }
      }

      setState(() {
        _detailedNutrition = {'nutrients': scaledNutrients};
        _loadingNutrition = false;
      });
    } catch (e) {
      setState(() {
        _loadingNutrition = false;
      });
      debugPrint('Error loading dish nutrition: $e');
    }
  }

  Future<void> _submitMeal() async {
    if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.pleaseSelectFoodOrDish);
            },
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // For dishes, use serving_size_g. For foods, use weight input
    double weight;
    if (_searchType == 'dish') {
      final servingSizeValue = _selectedFood!['serving_size_g'];
      weight = servingSizeValue != null
          ? (double.tryParse(servingSizeValue.toString()) ?? 100.0)
          : 100.0;
    } else {
      final inputWeight = double.tryParse(_weightController.text);
      if (inputWeight == null || inputWeight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.pleaseEnterValidAmount);
              },
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      weight = inputWeight;
    }

    // Check drug-nutrient interaction before submitting
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token != null) {
        final now = DateTime.now();
        final mealTime = now.toIso8601String();

        String? foodIds;
        if (_searchType == 'food') {
          foodIds = _selectedFood!['food_id'].toString();
        }

        final interactionResponse = await http.get(
          Uri.parse(
            '${ApiConfig.baseUrl}/api/medications/check-interaction?meal_time=$mealTime${foodIds != null ? '&food_ids=$foodIds' : ''}',
          ),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (interactionResponse.statusCode == 200) {
          final interactionData = json.decode(interactionResponse.body);
          if (interactionData['has_interaction'] == true) {
            final interactions = interactionData['interactions'] as List;
            final shouldContinue = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  _DrugInteractionWarningDialog(interactions: interactions),
            );

            if (shouldContinue != true) {
              return; // User cancelled
            }
          }
        }
      }
    } catch (e) {
      // If check fails, continue anyway (don't block user)
      debugPrint('Error checking drug interaction: $e');
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      Map<String, dynamic>? result;

      if (_searchType == 'dish') {
        // Add dish to meal
        result = await MealService.addDishToMeal(
          mealType: widget.mealType.toLowerCase(),
          dishId: _selectedFood!['dish_id'],
          weightG: weight,
        );
      } else {
        // Add food to meal
        result = await MealService.addFoodToMeal(
          mealType: widget.mealType.toLowerCase(),
          foodId: _selectedFood!['food_id'],
          weightG: weight,
        );
      }

      // Update profile provider with today's totals so Mediterranean diet updates immediately
      if (result != null && result['today'] != null) {
        final profile = context.maybeProfile();
        profile?.applyTodayTotals(result['today']);
      }

      // Unpin from smart suggestions if it was pinned
      if (_searchType == 'dish') {
        await SmartSuggestionService.unpinOnAdd(
          itemType: 'dish',
          itemId: _selectedFood!['dish_id'],
        );
      } else {
        await SmartSuggestionService.unpinOnAdd(
          itemType: 'food',
          itemId: _selectedFood!['food_id'],
        );
      }

      if (mounted) {
        Navigator.of(context).pop({
          'success': true,
          'type': _searchType,
          'id': _searchType == 'dish'
              ? _selectedFood!['dish_id']
              : _selectedFood!['food_id'],
          'name': _searchType == 'dish'
              ? (_selectedFood!['vietnamese_name'] ?? _selectedFood!['name'])
              : _selectedFood!['name'],
          'weight_g': weight,
        });

        // Refresh vitamin and mineral views
        VitaminView.refreshAll();
        MineralView.refreshAll();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.addedToMealSuccessfully);
              },
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            decoration: BoxDecoration(
              color: FitnessAppTheme.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchField(),
                        const SizedBox(height: 16),
                        if (_showQuickAdd &&
                            _quickAddSuggestions.isNotEmpty &&
                            _selectedFood == null)
                          _buildQuickAddSection(),
                        if (_isSearching) _buildLoadingIndicator(),
                        if (_searchResults.isNotEmpty && _selectedFood == null)
                          _buildSearchResults(),
                        if (_selectedFood != null) ...[
                          _buildSelectedFood(),
                          const SizedBox(height: 20),
                          // Only show portion suggestions for foods, not dishes
                          if (_searchType == 'food' &&
                              _portionSuggestions.isNotEmpty) ...[
                            _buildPortionSuggestions(),
                            const SizedBox(height: 16),
                          ],
                          _buildWeightInput(),
                          const SizedBox(height: 24),
                          _buildNutritionPreview(),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer Actions
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    IconData mealIcon = Icons.restaurant;
    String mealTitle = 'Add Meal';

    switch (widget.mealType.toLowerCase()) {
      case 'breakfast':
        mealIcon = Icons.free_breakfast;
        mealTitle = 'Add Meal - Breakfast';
        break;
      case 'lunch':
        mealIcon = Icons.lunch_dining;
        mealTitle = 'Add Meal - Lunch';
        break;
      case 'snack':
        mealIcon = Icons.cookie;
        mealTitle = 'Add Meal - Snack';
        break;
      case 'dinner':
        mealIcon = Icons.dinner_dining;
        mealTitle = 'Add Meal - Dinner';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FitnessAppTheme.nearlyBlue,
            FitnessAppTheme.nearlyBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(mealIcon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              mealTitle,
              style: const TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            tooltip: 'AI Image Analysis',
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiImageAnalysisScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search type toggle
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: _buildTypeButton(
                    'food',
                    l10n.ingredient,
                    Icons.food_bank,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton('dish', l10n.dish, Icons.restaurant),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        // Search input
        Container(
          decoration: BoxDecoration(
            color: FitnessAppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedFood != null
                  ? FitnessAppTheme.nearlyBlue
                  : FitnessAppTheme.grey.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _searchType == 'dish'
                  ? AppLocalizations.of(context)!.searchDish
                  : AppLocalizations.of(context)!.searchIngredient,
              hintStyle: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                color: FitnessAppTheme.grey,
              ),
              prefixIcon: Icon(Icons.search, color: FitnessAppTheme.nearlyBlue),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: FitnessAppTheme.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _selectedFood = null;
                          _searchResults = [];
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              setState(() {
                _selectedFood = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon) {
    final isSelected = _searchType == type;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _searchType = type;
              _searchResults = [];
              _selectedFood = null;
              _searchController.clear();
            });
            // Load initial data when switching tabs
            if (type == 'dish') {
              _loadInitialDishes();
            } else {
              _loadInitialFoods();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        FitnessAppTheme.nearlyBlue,
                        FitnessAppTheme.nearlyBlue.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? FitnessAppTheme.nearlyBlue
                    : FitnessAppTheme.grey.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : FitnessAppTheme.nearlyBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white
                        : FitnessAppTheme.nearlyDarkBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(FitnessAppTheme.nearlyBlue),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FitnessAppTheme.grey.withValues(alpha: 0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: FitnessAppTheme.grey.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final item = _searchResults[index];
          final name = _searchType == 'dish'
              ? (item['vietnamese_name'] ?? item['name'])
              : item['name'];
          final category = item['category'] ?? '';

          final bool isRestrictedFood =
              (_searchType == 'food' &&
                  item['food_id'] != null &&
                  _restrictedFoodIds.contains(item['food_id'])) ||
              (_searchType == 'dish' && item['is_restricted'] == true);

          // Check if item is pinned or is an ingredient of a pinned dish
          final bool isPinned =
              (_searchType == 'food' &&
                  item['food_id'] != null &&
                  (_pinnedFoodIds.contains(item['food_id']) ||
                      _pinnedIngredientFoodIds.contains(item['food_id']))) ||
              (_searchType == 'dish' &&
                  item['dish_id'] != null &&
                  _pinnedDishIds.contains(item['dish_id']));

          return Opacity(
            opacity: isRestrictedFood ? 0.45 : 1.0,
            child: InkWell(
              onTap: isRestrictedFood
                  ? () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: Text('Cảnh báo sức khỏe')),
                            ],
                          ),
                          content: Text(
                            '${item['name'] ?? item['vietnamese_name'] ?? 'Món'} không phù hợp với tình trạng sức khỏe của bạn. Bạn không nên ăn món này.',
                            style: const TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 14,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  : () async {
                      // If this is a dish and we don't yet know whether it's restricted,
                      // fall back to fetching details and checking ingredients.
                      if (_searchType == 'dish' &&
                          item['dish_id'] != null &&
                          item['is_restricted'] == null) {
                        final dishId = item['dish_id'];
                        bool blocked = false;
                        try {
                          final baseUrl = const String.fromEnvironment(
                            'API_URL',
                            defaultValue: ApiConfig.baseUrl,
                          );
                          final prefs = await SharedPreferences.getInstance();
                          final token =
                              prefs.getString('auth_token') ??
                              prefs.getString('token');
                          if (token != null) {
                            final resp = await http.get(
                              Uri.parse('$baseUrl/dishes/$dishId'),
                              headers: {'Authorization': 'Bearer $token'},
                            );
                            if (resp.statusCode == 200) {
                              final data = json.decode(resp.body);
                              final dish = data['data'] ?? data['dish'] ?? data;
                              final ingredients = List<dynamic>.from(
                                dish['ingredients'] ?? [],
                              );
                              for (final ing in ingredients) {
                                final fid = ing['food_id'] as int?;
                                if (fid != null &&
                                    _restrictedFoodIds.contains(fid)) {
                                  blocked = true;
                                  break;
                                }
                              }
                            }
                          }
                        } catch (e) {
                          // ignore
                        }

                        if (blocked) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text('Cảnh báo sức khỏe'),
                                  ),
                                ],
                              ),
                              content: Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return Text(
                                    '${l10n.dishContainsRestrictedFood}. Bạn không nên ăn món này.',
                                    style: const TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          // also mark the item to avoid repeated fetches
                          setState(() {
                            final idx = _searchResults.indexWhere(
                              (d) => d['dish_id'] == item['dish_id'],
                            );
                            if (idx != -1) {
                              _searchResults[idx] = Map<String, dynamic>.from(
                                _searchResults[idx],
                              )..['is_restricted'] = true;
                            }
                          });
                          return;
                        }
                      }
                      _selectFood(item);
                    },
              onLongPress: _searchType == 'food'
                  ? () => _showFoodDetailDialog(item)
                  : null,
              child: Container(
                decoration: isPinned
                    ? BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.nearlyBlue.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: FitnessAppTheme.nearlyBlue.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child:
                              item['image_url'] != null &&
                                  item['image_url'].toString().isNotEmpty
                              ? Image.network(
                                  item['image_url'].toString().startsWith(
                                        'http',
                                      )
                                      ? item['image_url']
                                      : '${ApiConfig.baseUrl}${item['image_url']}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        _searchType == 'dish'
                                            ? Icons.restaurant
                                            : Icons.food_bank,
                                        size: 24,
                                        color: FitnessAppTheme.nearlyBlue,
                                      ),
                                )
                              : Icon(
                                  _searchType == 'dish'
                                      ? Icons.restaurant
                                      : Icons.food_bank,
                                  size: 24,
                                  color: FitnessAppTheme.nearlyBlue,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name ?? '',
                                    style: const TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                // Show green badge for recommended foods or dishes
                                if ((_searchType == 'food' &&
                                        item['food_id'] != null &&
                                        _recommendedFoodIds.contains(
                                          item['food_id'],
                                        )) ||
                                    (_searchType == 'dish' &&
                                        item['is_recommended'] == true))
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          size: 12,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Nên dùng',
                                          style: TextStyle(
                                            fontFamily:
                                                FitnessAppTheme.fontName,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (category.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                category,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontSize: 11,
                                  color: FitnessAppTheme.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_searchType == 'food')
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 20),
                          color: FitnessAppTheme.nearlyBlue,
                          onPressed: () => _showFoodDetailDialog(item),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: FitnessAppTheme.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAddSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.history,
              size: 18,
              color: FitnessAppTheme.nearlyBlue,
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.quickAdd,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: FitnessAppTheme.nearlyBlue,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: FitnessAppTheme.nearlyBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Món ăn thường dùng',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 10,
                  color: FitnessAppTheme.nearlyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickAddSuggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final food = _quickAddSuggestions[index];
              final bool quickIsRestricted =
                  food['food_id'] != null &&
                  _restrictedFoodIds.contains(food['food_id']);

              return Opacity(
                opacity: quickIsRestricted ? 0.45 : 1.0,
                child: InkWell(
                  onTap: quickIsRestricted
                      ? () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text('Cảnh báo sức khỏe'),
                                  ),
                                ],
                              ),
                              content: Text(
                                '${AppLocalizations.of(context)!.foodRestrictedByHealthCondition(food['food_name'] ?? food['food_name_vi'] ?? 'Thực phẩm')}. Bạn không nên ăn thực phẩm này.',
                                style: const TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontSize: 14,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      : () {
                          // Quick add with average portion
                          final avgPortion = (food['avg_portion_g'] is num)
                              ? (food['avg_portion_g'] as num).toDouble()
                              : double.tryParse('${food['avg_portion_g']}') ??
                                    100.0;
                          _weightController.text = avgPortion.toStringAsFixed(
                            0,
                          );
                          _selectFood({
                            'food_id': food['food_id'],
                            'name': food['food_name'] ?? food['food_name_vi'],
                            'category': 'Quick Add',
                          });
                        },
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.1),
                          Colors.orange.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (food['is_favorite'] == true)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            food['food_name_vi'] ?? food['food_name'] ?? '',
                            style: const TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(food['avg_portion_g'] ?? 100).toString()}g',
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontSize: 10,
                            color: FitnessAppTheme.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Divider(height: 1, color: FitnessAppTheme.grey.withValues(alpha: 0.2)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPortionSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested Portions',
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: FitnessAppTheme.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _portionSuggestions.take(6).map((portion) {
            final weightGRaw = portion['weight_g'];
            final weightG = weightGRaw is String
                ? (double.tryParse(weightGRaw) ?? 100.0)
                : (weightGRaw is num ? weightGRaw.toDouble() : 100.0);
            final name = portion['portion_name_vi'] ?? portion['portion_name'];

            return InkWell(
              onTap: () {
                setState(() {
                  _weightController.text = weightG.toStringAsFixed(0);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _weightController.text == weightG.toStringAsFixed(0)
                      ? FitnessAppTheme.nearlyBlue
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _weightController.text == weightG.toStringAsFixed(0)
                        ? FitnessAppTheme.nearlyBlue
                        : FitnessAppTheme.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$name (${weightG.toStringAsFixed(0)}g)',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: _weightController.text == weightG.toStringAsFixed(0)
                        ? Colors.white
                        : FitnessAppTheme.darkerText,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedFood() {
    final name = _searchType == 'dish'
        ? (_selectedFood!['vietnamese_name'] ?? _selectedFood!['name'])
        : _selectedFood!['name'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FitnessAppTheme.nearlyBlue.withValues(alpha: 0.1),
            FitnessAppTheme.nearlyBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FitnessAppTheme.nearlyBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FitnessAppTheme.nearlyBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child:
                  _selectedFood!['image_url'] != null &&
                      _selectedFood!['image_url'].toString().isNotEmpty
                  ? Image.network(
                      _selectedFood!['image_url'].toString().startsWith('http')
                          ? _selectedFood!['image_url']
                          : '${ApiConfig.baseUrl}${_selectedFood!['image_url']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        _searchType == 'dish'
                            ? Icons.restaurant
                            : Icons.food_bank,
                        size: 32,
                        color: FitnessAppTheme.nearlyBlue,
                      ),
                    )
                  : Icon(
                      _searchType == 'dish'
                          ? Icons.restaurant
                          : Icons.food_bank,
                      size: 32,
                      color: FitnessAppTheme.nearlyBlue,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name ?? '',
                        style: const TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.nearlyBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _searchType == 'dish' ? 'Món Ăn' : 'Nguyên Liệu',
                        style: const TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedFood!['category'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _selectedFood!['category'],
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 12,
                      color: FitnessAppTheme.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput() {
    // For dishes, we don't show weight input - use serving_size_g
    if (_searchType == 'dish') {
      final servingSizeValue = _selectedFood?['serving_size_g'];
      // Handle both String (from PostgreSQL numeric) and num types
      final servingSize = servingSizeValue != null
          ? (double.tryParse(servingSizeValue.toString()) ?? 100.0)
          : 100.0;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Khẩu phần: ${servingSize.toStringAsFixed(0)}g (cố định)',
                style: const TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 13,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // For foods, show weight input
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Weight',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: FitnessAppTheme.darkerText,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'grams',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 11,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: FitnessAppTheme.nearlyBlue.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: '100',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildQuickWeightButton(50),
            const SizedBox(width: 8),
            _buildQuickWeightButton(100),
            const SizedBox(width: 8),
            _buildQuickWeightButton(200),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickWeightButton(int weight) {
    return InkWell(
      onTap: () {
        setState(() {
          _weightController.text = weight.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _weightController.text == weight.toString()
              ? FitnessAppTheme.nearlyBlue
              : FitnessAppTheme.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _weightController.text == weight.toString()
                ? FitnessAppTheme.nearlyBlue
                : FitnessAppTheme.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          '${weight}g',
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: _weightController.text == weight.toString()
                ? Colors.white
                : FitnessAppTheme.darkerText,
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionPreview() {
    final weight = double.tryParse(_weightController.text) ?? 100;

    if (_loadingNutrition) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // If we have detailed nutrition from API, show it
    if (_detailedNutrition != null) {
      final nutrients =
          _detailedNutrition!['nutrients'] as Map<String, dynamic>?;

      if (nutrients == null || nutrients.isEmpty) {
        return _buildNoNutritionData(weight);
      }

      // Group nutrients by category
      final macros = <String, Map<String, dynamic>>{};
      final vitamins = <String, Map<String, dynamic>>{};
      final minerals = <String, Map<String, dynamic>>{};
      final aminoAcids = <String, Map<String, dynamic>>{};
      final others = <String, Map<String, dynamic>>{};

      nutrients.forEach((name, data) {
        final nameLower = name.toLowerCase();
        if (nameLower.contains('protein') ||
            nameLower.contains('fat') ||
            nameLower.contains('carbohydrate') ||
            nameLower.contains('energy') ||
            nameLower.contains('calorie')) {
          macros[name] = data;
        } else if (nameLower.contains('vitamin') || nameLower.contains('vit')) {
          vitamins[name] = data;
        } else if (nameLower.contains('calcium') ||
            nameLower.contains('iron') ||
            nameLower.contains('magnesium') ||
            nameLower.contains('zinc') ||
            nameLower.contains('potassium') ||
            nameLower.contains('sodium') ||
            nameLower.contains('phosphorus') ||
            nameLower.contains('copper') ||
            nameLower.contains('manganese') ||
            nameLower.contains('selenium')) {
          minerals[name] = data;
        } else if (nameLower.contains('leucine') ||
            nameLower.contains('lysine') ||
            nameLower.contains('valine') ||
            nameLower.contains('isoleucine') ||
            nameLower.contains('threonine') ||
            nameLower.contains('tryptophan') ||
            nameLower.contains('methionine') ||
            nameLower.contains('phenylalanine') ||
            nameLower.contains('histidine')) {
          aminoAcids[name] = data;
        } else {
          others[name] = data;
        }
      });

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withValues(alpha: 0.1),
              Colors.green.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dinh dưỡng cho ${weight.toStringAsFixed(0)}g',
                    style: const TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Macros Section
            if (macros.isNotEmpty) ...[
              _buildNutrientSection(
                'Macros',
                Icons.restaurant,
                Colors.orange,
                macros,
              ),
              const SizedBox(height: 12),
            ],

            // Vitamins Section
            if (vitamins.isNotEmpty) ...[
              _buildNutrientSection(
                'Vitamins',
                Icons.local_pharmacy,
                Colors.purple,
                vitamins,
              ),
              const SizedBox(height: 12),
            ],

            // Minerals Section
            if (minerals.isNotEmpty) ...[
              _buildNutrientSection(
                'Khoáng chất',
                Icons.diamond,
                Colors.cyan,
                minerals,
              ),
              const SizedBox(height: 12),
            ],

            // Amino Acids Section
            if (aminoAcids.isNotEmpty) ...[
              _buildNutrientSection(
                'Amino Acids',
                Icons.science,
                Colors.pink,
                aminoAcids,
              ),
              const SizedBox(height: 12),
            ],

            // Others Section
            if (others.isNotEmpty)
              _buildNutrientSection('Khác', Icons.eco, Colors.blue, others),
          ],
        ),
      );
    }

    return _buildNoNutritionData(weight);
  }

  Widget _buildNutrientSection(
    String title,
    IconData icon,
    Color color,
    Map<String, Map<String, dynamic>> nutrients,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: nutrients.entries.take(10).map((entry) {
              final amount = (entry.value['amount'] as num?)?.toDouble() ?? 0.0;
              final unit = entry.value['unit'] as String? ?? 'g';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '${_formatNutrientName(entry.key)}: ${amount.toStringAsFixed(1)} $unit',
                  style: const TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          if (nutrients.length > 10) ...[
            const SizedBox(height: 4),
            Text(
              '+${nutrients.length - 10} more...',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 10,
                color: FitnessAppTheme.grey.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatNutrientName(String name) {
    // Shorten long nutrient names
    if (name.length > 20) {
      return '${name.substring(0, 17)}...';
    }
    return name;
  }

  Widget _buildNoNutritionData(double weight) {
    // Fallback to simple message
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Estimated Nutrition',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Based on ${weight.toStringAsFixed(0)}g, nutrition will be calculated from the database and added to your daily totals.',
            style: const TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 12,
              color: FitnessAppTheme.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FitnessAppTheme.background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: FitnessAppTheme.grey.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: FitnessAppTheme.darkerText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting || _selectedFood == null
                  ? null
                  : _submitMeal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: FitnessAppTheme.nearlyBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Add Meal',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Drug Interaction Warning Dialog
class _DrugInteractionWarningDialog extends StatelessWidget {
  final List<dynamic> interactions;

  const _DrugInteractionWarningDialog({required this.interactions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[700], size: 28),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Cảnh báo tương tác thuốc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn vừa uống thuốc và thực phẩm này có thể tương tác:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...interactions.map(
              (interaction) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: interaction['severity'] == 'severe'
                      ? Colors.red[50]
                      : interaction['severity'] == 'moderate'
                      ? Colors.orange[50]
                      : Colors.yellow[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: interaction['severity'] == 'severe'
                        ? Colors.red[300]!
                        : interaction['severity'] == 'moderate'
                        ? Colors.orange[300]!
                        : Colors.yellow[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.medication,
                          size: 20,
                          color: interaction['severity'] == 'severe'
                              ? Colors.red[700]
                              : Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            interaction['drug_name_vi'] ?? 'Thuốc',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: interaction['severity'] == 'severe'
                                  ? Colors.red[900]
                                  : Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      interaction['warning_message_vi'] ??
                          'Có tương tác với ${interaction['nutrient_name']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chất dinh dưỡng: ${interaction['nutrient_name'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn có chắc muốn tiếp tục?',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
          child: const Text(
            'Vẫn tiếp tục',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
