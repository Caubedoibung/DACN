import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class WebAdminFoods extends StatefulWidget {
  const WebAdminFoods({super.key});

  @override
  State<WebAdminFoods> createState() => _WebAdminFoodsState();
}

class _WebAdminFoodsState extends State<WebAdminFoods> {
  List<dynamic> _foods = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods({int page = 1, String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/admin/foods?page=$page&limit=20&search=$search',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _foods = data['foods'] ?? [];
          _currentPage = data['pagination']?['page'] ?? 1;
          _totalPages = data['pagination']?['totalPages'] ?? 1;
          _totalItems = data['pagination']?['total'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSearch(String query) async {
    _searchQuery = query;
    await _loadFoods(page: 1, search: query);
  }

  Future<void> _showFoodDetails(Map<String, dynamic> food) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/foods/${food['food_id']}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foodData = data['food'];
        final nutrients = data['nutrients'] ?? [];

        if (mounted) {
          await WebDialog.show(
            context: context,
            title: 'Chi tiết thực phẩm',
            width: 700,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (foodData['image_url'] != null)
                    Center(
                      child: Image.network(
                        foodData['image_url'],
                        height: 150,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.restaurant, size: 100),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Tên', foodData['name'] ?? 'N/A'),
                  _buildDetailRow('Danh mục', foodData['category'] ?? 'N/A'),
                  _buildDetailRow(
                      'Khẩu phần', '${foodData['serving_size_g'] ?? 0}g'),
                  if (nutrients.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Thông tin dinh dưỡng (per 100g)',
                      style: TextStyle(
                        fontSize: 16,
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
                                '${nutrient['amount_per_100g'] ?? 0} ${nutrient['unit'] ?? ''}',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _deleteFood(int foodId, String foodName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa thực phẩm "$foodName"?'),
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
        Uri.parse('${ApiConfig.baseUrl}/admin/foods/$foodId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa thực phẩm thành công')),
          );
        }
        _loadFoods(page: _currentPage, search: _searchQuery);
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
      child: WebDataTable<Map<String, dynamic>>(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Danh mục')),
          DataColumn(label: Text('Khẩu phần')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: _foods.cast<Map<String, dynamic>>(),
        rowBuilder: (context, food, index) {
          return DataRow(
            cells: [
              DataCell(Text('${food['food_id'] ?? ''}')),
              DataCell(Text(food['name'] ?? 'N/A')),
              DataCell(Text(food['category'] ?? 'Chưa phân loại')),
              DataCell(Text('${food['serving_size_g'] ?? 0}g')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      onPressed: () => _showFoodDetails(food),
                      tooltip: 'Xem chi tiết',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit,
                          size: 18, color: Colors.orange),
                      onPressed: () {},
                      tooltip: 'Chỉnh sửa',
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () => _deleteFood(
                        food['food_id'],
                        food['name'] ?? 'thực phẩm',
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
        totalItems: _totalItems,
        onPageChanged: (page) => _loadFoods(page: page, search: _searchQuery),
        searchHint: 'Tìm kiếm thực phẩm...',
        onSearch: _handleSearch,
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
