import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class WebAdminDashboard extends StatefulWidget {
  const WebAdminDashboard({super.key});

  @override
  State<WebAdminDashboard> createState() => _WebAdminDashboardState();
}

class _WebAdminDashboardState extends State<WebAdminDashboard>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? stats;
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> categoryData = {};
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _loadAllData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => isLoading = true);
    await Future.wait([
      _loadStats(),
      _loadFoodCategories(),
      _loadDishCategories(),
      _loadDrinkCategories(),
      _loadNutrientCategories(),
      _loadHealthConditionCategories(),
      _loadDrugCategories(),
    ]);
    if (mounted) {
      setState(() => isLoading = false);
      _controller.forward();
    }
  }

  Future<void> _loadStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/dashboard/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          stats = json.decode(response.body);
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _loadFoodCategories() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/foods/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categoryData['foods'] = List<Map<String, dynamic>>.from(
            data['byCategory'] ?? [],
          );
        });
      }
    } catch (e) {
      // Use placeholder
      setState(() {
        categoryData['foods'] = [];
      });
    }
  }

  Future<void> _loadDishCategories() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/dishes/categories'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categoryData['dishes'] = List<Map<String, dynamic>>.from(
            data['categories'] ?? data ?? [],
          );
        });
      }
    } catch (e) {
      // Use placeholder
      setState(() {
        categoryData['dishes'] = [];
      });
    }
  }

  Future<void> _loadDrinkCategories() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/drinks/categories'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categoryData['drinks'] = List<Map<String, dynamic>>.from(
            data['categories'] ?? data ?? [],
          );
        });
      }
    } catch (e) {
      // Query directly if endpoint doesn't exist
      try {
        final token = await AuthService.getToken();
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/drinks'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final drinks = List<Map<String, dynamic>>.from(data['drinks'] ?? []);
          final categoryMap = <String, int>{};
          for (var drink in drinks) {
            final cat = drink['category'] ?? 'Khác';
            categoryMap[cat] = (categoryMap[cat] ?? 0) + 1;
          }
          setState(() {
            categoryData['drinks'] = categoryMap.entries
                .map((e) => {'category': e.key, 'count': e.value})
                .toList();
          });
        }
      } catch (_) {
        setState(() {
          categoryData['drinks'] = [];
        });
      }
    }
  }

  Future<void> _loadNutrientCategories() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/nutrients'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nutrients = List<Map<String, dynamic>>.from(
          data['nutrients'] ?? data ?? [],
        );
        final categoryMap = <String, int>{};
        for (var nutrient in nutrients) {
          final cat = nutrient['category'] ?? nutrient['type'] ?? 'Khác';
          categoryMap[cat] = (categoryMap[cat] ?? 0) + 1;
        }
        setState(() {
          categoryData['nutrients'] = categoryMap.entries
              .map((e) => {'category': e.key, 'count': e.value})
              .toList();
        });
      }
    } catch (e) {
      setState(() {
        categoryData['nutrients'] = [];
      });
    }
  }

  Future<void> _loadHealthConditionCategories() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/health-conditions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conditions = List<Map<String, dynamic>>.from(
          data['conditions'] ?? data ?? [],
        );
        final categoryMap = <String, int>{};
        for (var condition in conditions) {
          final cat = condition['category'] ?? 'Khác';
          categoryMap[cat] = (categoryMap[cat] ?? 0) + 1;
        }
        setState(() {
          categoryData['health_conditions'] = categoryMap.entries
              .map((e) => {'category': e.key, 'count': e.value})
              .toList();
        });
      }
    } catch (e) {
      setState(() {
        categoryData['health_conditions'] = [];
      });
    }
  }

  Future<void> _loadDrugCategories() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/drugs'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final drugs = List<Map<String, dynamic>>.from(
          data['drugs'] ?? data ?? [],
        );
        final categoryMap = <String, int>{};
        for (var drug in drugs) {
          final cat = drug['category'] ?? drug['drug_type'] ?? 'Khác';
          categoryMap[cat] = (categoryMap[cat] ?? 0) + 1;
        }
        setState(() {
          categoryData['drugs'] = categoryMap.entries
              .map((e) => {'category': e.key, 'count': e.value})
              .toList();
        });
      }
    } catch (e) {
      setState(() {
        categoryData['drugs'] = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // Bar Chart - Thống kê số lượng
          _buildQuantityBarChart(),
          const SizedBox(height: 24),

          // Category Pie Charts - Row 1
          _buildCategoryChartsRow([
            {'title': 'Thực phẩm', 'key': 'foods', 'color': Colors.green},
            {'title': 'Món ăn', 'key': 'dishes', 'color': Colors.teal},
          ]),
          const SizedBox(height: 24),

          // Category Pie Charts - Row 2
          _buildCategoryChartsRow([
            {'title': 'Đồ uống', 'key': 'drinks', 'color': Colors.cyan},
            {
              'title': 'Chất dinh dưỡng',
              'key': 'nutrients',
              'color': Colors.orange
            },
          ]),
          const SizedBox(height: 24),

          // Category Pie Charts - Row 3
          _buildCategoryChartsRow([
            {
              'title': 'Bệnh lý',
              'key': 'health_conditions',
              'color': Colors.red
            },
            {'title': 'Thuốc', 'key': 'drugs', 'color': Colors.purple},
          ]),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final statItems = [
      {
        'title': 'Tổng người dùng',
        'value': stats!['total_users'] ?? 0,
        'icon': Icons.people_alt_rounded,
        'color': Colors.teal.shade600,
        'gradient': [Colors.teal.shade400, Colors.teal.shade600],
      },
      {
        'title': 'Thực phẩm',
        'value': stats!['total_foods'] ?? 0,
        'icon': Icons.eco_rounded,
        'color': Colors.green.shade600,
        'gradient': [Colors.green.shade400, Colors.green.shade600],
      },
      {
        'title': 'Món ăn',
        'value': stats!['total_dishes'] ?? 0,
        'icon': Icons.restaurant_rounded,
        'color': Colors.lightGreen.shade600,
        'gradient': [Colors.lightGreen.shade400, Colors.lightGreen.shade600],
      },
      {
        'title': 'Đồ uống',
        'value': stats!['total_drinks'] ?? 0,
        'icon': Icons.local_cafe_rounded,
        'color': Colors.cyan.shade600,
        'gradient': [Colors.cyan.shade400, Colors.cyan.shade600],
      },
      {
        'title': 'Chất dinh dưỡng',
        'value': stats!['total_nutrients'] ?? 0,
        'icon': Icons.auto_awesome_rounded,
        'color': Colors.amber.shade600,
        'gradient': [Colors.amber.shade400, Colors.amber.shade600],
      },
      {
        'title': 'Bệnh lý',
        'value': stats!['total_health_conditions'] ?? 0,
        'icon': Icons.favorite_rounded,
        'color': Colors.pink.shade400,
        'gradient': [Colors.pink.shade300, Colors.pink.shade500],
      },
      {
        'title': 'Thuốc',
        'value': stats!['total_drugs'] ?? 0,
        'icon': Icons.medical_services_rounded,
        'color': Colors.deepPurple.shade400,
        'gradient': [Colors.deepPurple.shade300, Colors.deepPurple.shade500],
      },
      {
        'title': 'Hoạt động hôm nay',
        'value': stats!['today_meals'] ?? 0,
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.orange.shade600,
        'gradient': [Colors.orange.shade400, Colors.orange.shade600],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8,
      ),
      itemCount: statItems.length,
      itemBuilder: (context, index) {
        final item = statItems[index];
        return FadeTransition(
          opacity: _fadeAnimation,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: item['gradient'] as List<Color>,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (item['color'] as Color).withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {},
                        splashColor: Colors.white.withValues(alpha: 0.1),
                        highlightColor: Colors.white.withValues(alpha: 0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item['value'].toString(),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.0,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white
                                            .withValues(alpha: 0.95),
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuantityBarChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê số lượng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = [
                            'Người dùng',
                            'Thực phẩm',
                            'Món ăn',
                            'Đồ uống',
                            'Chất DD',
                            'Bệnh lý',
                            'Thuốc',
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_users'] ?? 0).toDouble(),
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_foods'] ?? 0).toDouble(),
                          color: Colors.green,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_dishes'] ?? 0).toDouble(),
                          color: Colors.teal,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_drinks'] ?? 0).toDouble(),
                          color: Colors.cyan,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_nutrients'] ?? 0).toDouble(),
                          color: Colors.orange,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_health_conditions'] ?? 0)
                              .toDouble(),
                          color: Colors.red,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_drugs'] ?? 0).toDouble(),
                          color: Colors.purple,
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChartsRow(List<Map<String, dynamic>> items) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildCategoryPieChart(
              item['title'] as String,
              item['key'] as String,
              item['color'] as Color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryPieChart(String title, String key, Color color) {
    final data = categoryData[key] ?? [];
    final total = data.fold<int>(
      0,
      (sum, item) => sum + ((item['count'] ?? 0) as int),
    );

    if (total == 0 || data.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Chưa có dữ liệu'),
            ],
          ),
        ),
      );
    }

    // Define a list of unique colors for chart segments
    final List<Color> uniqueColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
      Colors.pink,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
      Colors.lime,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.yellow,
      Colors.grey,
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: data.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final count = (item['count'] ?? 0) as int;
                          final percentage =
                              (count / total * 100).toStringAsFixed(1);
                          return PieChartSectionData(
                            value: count.toDouble(),
                            title: '$percentage%',
                            color: uniqueColors[index % uniqueColors.length],
                            radius: 60,
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: data.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final category = item['category'] ?? 'Khác';
                        final count = (item['count'] ?? 0) as int;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color:
                                      uniqueColors[index % uniqueColors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
