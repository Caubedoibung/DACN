import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class WebAdminDishes extends StatefulWidget {
  const WebAdminDishes({super.key});

  @override
  State<WebAdminDishes> createState() => _WebAdminDishesState();
}

class _WebAdminDishesState extends State<WebAdminDishes> {
  List<dynamic> _dishes = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String? _selectedCategory;
  bool? _filterTemplate;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadDishes(), _loadCategories()]);
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final queryParams = <String, String>{};

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }
      if (_selectedCategory != null) {
        queryParams['category'] = _selectedCategory!;
      }
      if (_filterTemplate != null) {
        queryParams['isTemplate'] = _filterTemplate.toString();
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/dishes/admin/all',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _dishes = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/categories'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categories = data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _showDishDetails(int dishId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final nutrientsResponse = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId/nutrients'),
          headers: {'Authorization': 'Bearer $token'},
        );
        List<dynamic> nutrients = [];
        if (nutrientsResponse.statusCode == 200) {
          final nutrientsData = json.decode(nutrientsResponse.body);
          nutrients = nutrientsData['data'] ?? [];
        }

        if (mounted) {
          await WebDialog.show(
            context: context,
            title: 'Chi tiết món ăn',
            width: 800,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['vietnamese_name'] ?? data['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (data['name'] != null)
                    Text(
                      data['name'],
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category, size: 16),
                        label: Text(data['category'] ?? 'N/A'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.scale, size: 16),
                        label: Text('${data['serving_size_g']}g'),
                      ),
                      Chip(
                        avatar: Icon(
                          data['is_template'] ? Icons.star : Icons.person,
                          size: 16,
                        ),
                        label: Text(
                          data['is_template'] ? 'Món mẫu' : 'Người dùng tạo',
                        ),
                      ),
                    ],
                  ),
                  if (data['description'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      data['description'],
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                  if (nutrients.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Thông tin dinh dưỡng (per 100g)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...nutrients.take(10).map((nutrient) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(nutrient['nutrient_name'] ?? 'N/A'),
                              Text(
                                '${nutrient['amount_per_100g']} ${nutrient['unit'] ?? ''}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _deleteDish(int dishId, String dishName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa món "$dishName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/dishes/$dishId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa món ăn')),
          );
        }
        _loadDishes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Loại món',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        ..._categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat['category'],
                            child: Text('${cat['category']} (${cat['count']})'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                        _loadDishes();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      initialValue: _filterTemplate,
                      decoration: const InputDecoration(
                        labelText: 'Loại',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Món mẫu'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Người dùng tạo'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _filterTemplate = value);
                        _loadDishes();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Table
          Expanded(
            child: WebDataTable<Map<String, dynamic>>(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Tên')),
                DataColumn(label: Text('Loại')),
                DataColumn(label: Text('Danh mục')),
                DataColumn(label: Text('Nguyên liệu')),
                DataColumn(label: Text('Thao tác')),
              ],
              rows: _dishes.cast<Map<String, dynamic>>(),
              rowBuilder: (context, dish, index) {
                return DataRow(
                  cells: [
                    DataCell(Text('${dish['dish_id'] ?? ''}')),
                    DataCell(Text(
                      dish['vietnamese_name'] ?? dish['name'] ?? 'N/A',
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            dish['is_template'] ? Icons.star : Icons.person,
                            size: 16,
                            color: dish['is_template']
                                ? Colors.orange
                                : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dish['is_template'] ? 'Mẫu' : 'User',
                            style: TextStyle(
                              fontSize: 12,
                              color: dish['is_template']
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(dish['category'] ?? 'N/A')),
                    DataCell(Text('${dish['ingredient_count'] ?? 0} NL')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            onPressed: () => _showDishDetails(dish['dish_id']),
                            tooltip: 'Xem chi tiết',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                size: 18, color: Colors.red),
                            onPressed: () => _deleteDish(
                              dish['dish_id'],
                              dish['vietnamese_name'] ??
                                  dish['name'] ??
                                  'món ăn',
                            ),
                            tooltip: 'Xóa',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              isLoading: _isLoading,
              currentPage: _currentPage,
              totalPages: _totalPages,
              totalItems: _dishes.length,
              onPageChanged: null,
              searchHint: 'Tìm kiếm món ăn...',
              onSearch: (query) {
                _searchQuery = query;
                _loadDishes();
              },
              actions: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
