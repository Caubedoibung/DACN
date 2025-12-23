import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../services/auth_service.dart';

class RDARecommendationsScreen extends StatefulWidget {
  const RDARecommendationsScreen({super.key});

  @override
  createState() => _RDARecommendationsScreenState();
}

class _RDARecommendationsScreenState extends State<RDARecommendationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  
  // Expandable state for each nutrient group
  final Map<String, bool> _expandedGroups = {
    'vitamins': false,
    'minerals': false,
    'amino_acids': false,
    'fiber': false,
    'fatty_acids': false,
  };

  // WHO RDA data by age/gender
  final Map<String, List<Map<String, dynamic>>> _rdaData = {
    'vitamins': [
      {'name': 'Vitamin A', 'male': '900 µg', 'female': '700 µg', 'icon': '🥕'},
      {'name': 'Vitamin D', 'male': '15 µg', 'female': '15 µg', 'icon': '☀️'},
      {'name': 'Vitamin C', 'male': '90 mg', 'female': '75 mg', 'icon': '🍊'},
      {'name': 'Vitamin E', 'male': '15 mg', 'female': '15 mg', 'icon': '🥜'},
      {'name': 'Vitamin K', 'male': '120 µg', 'female': '90 µg', 'icon': '🥬'},
      {'name': 'Vitamin B1 (Thiamine)', 'male': '1.2 mg', 'female': '1.1 mg', 'icon': '🌾'},
      {'name': 'Vitamin B2 (Riboflavin)', 'male': '1.3 mg', 'female': '1.1 mg', 'icon': '🥛'},
      {'name': 'Vitamin B6', 'male': '1.3 mg', 'female': '1.3 mg', 'icon': '🐟'},
      {'name': 'Vitamin B9 (Folate)', 'male': '400 µg', 'female': '400 µg', 'icon': '🥗'},
      {'name': 'Vitamin B12', 'male': '2.4 µg', 'female': '2.4 µg', 'icon': '🥩'},
    ],
    'minerals': [
      {'name': 'Calcium (Ca)', 'male': '1000 mg', 'female': '1000 mg', 'icon': '🥛'},
      {'name': 'Iron (Fe)', 'male': '8 mg', 'female': '18 mg', 'icon': '🥩'},
      {'name': 'Magnesium (Mg)', 'male': '420 mg', 'female': '320 mg', 'icon': '🥜'},
      {'name': 'Zinc (Zn)', 'male': '11 mg', 'female': '8 mg', 'icon': '🦪'},
      {'name': 'Potassium (K)', 'male': '3400 mg', 'female': '2600 mg', 'icon': '🍌'},
      {'name': 'Sodium (Na)', 'male': '1500 mg', 'female': '1500 mg', 'icon': '🧂'},
      {'name': 'Phosphorus (P)', 'male': '700 mg', 'female': '700 mg', 'icon': '🧀'},
      {'name': 'Iodine (I)', 'male': '150 µg', 'female': '150 µg', 'icon': '🐠'},
      {'name': 'Selenium (Se)', 'male': '55 µg', 'female': '55 µg', 'icon': '🌰'},
      {'name': 'Copper (Cu)', 'male': '900 µg', 'female': '900 µg', 'icon': '🍫'},
      {'name': 'Manganese (Mn)', 'male': '2.3 mg', 'female': '1.8 mg', 'icon': '🫘'},
    ],
    'amino_acids': [
      {'name': 'Histidine', 'adult': '14 mg/kg', 'icon': '🥩'},
      {'name': 'Isoleucine', 'adult': '19 mg/kg', 'icon': '🍗'},
      {'name': 'Leucine', 'adult': '42 mg/kg', 'icon': '🥚'},
      {'name': 'Lysine', 'adult': '38 mg/kg', 'icon': '🐟'},
      {'name': 'Methionine', 'adult': '19 mg/kg', 'icon': '🧀'},
      {'name': 'Phenylalanine', 'adult': '33 mg/kg', 'icon': '🥛'},
      {'name': 'Threonine', 'adult': '20 mg/kg', 'icon': '🍖'},
      {'name': 'Tryptophan', 'adult': '5 mg/kg', 'icon': '🍗'},
      {'name': 'Valine', 'adult': '24 mg/kg', 'icon': '🥩'},
    ],
    'fiber': [
      {'name': 'Total Dietary Fiber', 'male': '38 g', 'female': '25 g', 'icon': '🌾'},
      {'name': 'Soluble Fiber', 'adult': '10-15 g', 'icon': '🍎'},
      {'name': 'Insoluble Fiber', 'adult': '10-15 g', 'icon': '🥦'},
      {'name': 'Beta-Glucan', 'adult': '3 g', 'icon': '🌾'},
    ],
    'fatty_acids': [
      {'name': 'Omega-3 (ALA)', 'male': '1.6 g', 'female': '1.1 g', 'icon': '🥜'},
      {'name': 'EPA + DHA', 'adult': '250-500 mg', 'icon': '🐟'},
      {'name': 'Omega-6 (LA)', 'male': '17 g', 'female': '12 g', 'icon': '🌻'},
      {'name': 'Total PUFA', 'adult': '5-10% energy', 'icon': '🥑'},
      {'name': 'Total MUFA', 'adult': '15-20% energy', 'icon': '🫒'},
      {'name': 'Saturated Fat', 'adult': '<10% energy', 'icon': '🧈'},
      {'name': 'Trans Fat', 'adult': '<1% energy', 'icon': '⚠️'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadUserProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.me();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getAgeGroup() {
    if (_userProfile == null || _userProfile!['age'] == null) return 'adult';
    final age = _userProfile!['age'];
    if (age < 1) return '0-6 months';
    if (age < 4) return '1-3 years';
    if (age < 9) return '4-8 years';
    if (age < 14) return '9-13 years';
    if (age < 19) return '14-18 years';
    if (age < 51) return '19-50 years';
    return '51+ years';
  }

  String _getGender() {
    return _userProfile?['gender']?.toLowerCase() ?? 'male';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: Column(
        children: [
          _buildAppBar(),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: _buildContent(),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        boxShadow: [
          BoxShadow(
            color: FitnessAppTheme.grey.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: FitnessAppTheme.nearlyBlack),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhu Cầu Dinh Dưỡng Khuyến Nghị',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: FitnessAppTheme.nearlyBlack,
                      ),
                    ),
                    if (_userProfile != null)
                      Text(
                        '${_getGender() == 'male' ? 'Nam' : 'Nữ'}, ${_getAgeGroup()} • Tiêu chuẩn WHO',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 12,
                          color: FitnessAppTheme.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _animationController,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildNutrientGroup(
            'vitamins',
            'Vitamins',
            '💊',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildNutrientGroup(
            'minerals',
            'Minerals',
            '⚗️',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildNutrientGroup(
            'amino_acids',
            'Amino Acids (Essential)',
            '🧬',
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildNutrientGroup(
            'fiber',
            'Dietary Fiber',
            '🌾',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildNutrientGroup(
            'fatty_acids',
            'Fatty Acids',
            '🥑',
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FitnessAppTheme.nearlyBlue,
            FitnessAppTheme.nearlyBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Giá trị khuyến nghị dựa trên tiêu chuẩn WHO và tự động cập nhật theo tuổi, giới tính của bạn.',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 13,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientGroup(String key, String title, String emoji, Color color) {
    final isExpanded = _expandedGroups[key] ?? false;
    final nutrients = _rdaData[key] ?? [];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (key.hashCode % 3) * 100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedGroups[key] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: FitnessAppTheme.nearlyBlack,
                            ),
                          ),
                          Text(
                            '${nutrients.length} chất dinh dưỡng',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 12,
                              color: FitnessAppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  children: nutrients.map((nutrient) {
                    return _buildNutrientItem(nutrient, color);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientItem(Map<String, dynamic> nutrient, Color color) {
    final gender = _getGender();
    String recommendation = '';
    
    if (nutrient.containsKey('male') && nutrient.containsKey('female')) {
      recommendation = gender == 'male' ? nutrient['male'] : nutrient['female'];
    } else if (nutrient.containsKey('adult')) {
      recommendation = nutrient['adult'];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: FitnessAppTheme.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            nutrient['icon'] ?? '•',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nutrient['name'],
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 14,
                color: FitnessAppTheme.nearlyBlack,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              recommendation,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
