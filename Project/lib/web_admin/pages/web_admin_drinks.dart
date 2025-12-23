import 'package:flutter/material.dart';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../services/drink_service.dart';

class WebAdminDrinks extends StatefulWidget {
  const WebAdminDrinks({super.key});

  @override
  State<WebAdminDrinks> createState() => _WebAdminDrinksState();
}

class _WebAdminDrinksState extends State<WebAdminDrinks> {
  List<Map<String, dynamic>> _drinks = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  Future<void> _loadDrinks() async {
    setState(() => _isLoading = true);
    final drinks = await DrinkService.adminFetchDrinks();
    if (!mounted) return;
    setState(() {
      _drinks = drinks;
      _isLoading = false;
    });
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _showDrinkDetails(Map<String, dynamic> drink) async {
    try {
      final detail = await DrinkService.fetchDetail(drink['drink_id'] as int);
      if (detail == null || !mounted) return;

      final drinkData = detail['drink'];
      final nutrients = drinkData['nutrients'] ?? {};

      await WebDialog.show(
        context: context,
        title: 'Chi tiết đồ uống',
        width: 700,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drinkData['vietnamese_name'] ?? drinkData['name'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (drinkData['name'] != null)
                Text(
                  drinkData['name'],
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),
              if (drinkData['description'] != null)
                Text(
                  drinkData['description'],
                  style: TextStyle(color: Colors.grey[700]),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.water_drop, size: 16),
                    label: Text(
                      'Hydration ${(_toDouble(drinkData['hydration_ratio']) * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                  if (drinkData['default_volume_ml'] != null)
                    Chip(
                      avatar: const Icon(Icons.local_drink, size: 16),
                      label: Text('${drinkData['default_volume_ml']} ml'),
                    ),
                  if (nutrients['ENERC_KCAL'] != null)
                    Chip(
                      avatar: const Icon(Icons.bolt, size: 16),
                      label: Text('${nutrients['ENERC_KCAL']} kcal/100ml'),
                    ),
                ],
              ),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _deleteDrink(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa đồ uống "$name"?'),
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

    final ok = await DrinkService.adminDeleteDrink(id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa đồ uống')),
      );
      _loadDrinks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDrinks = _searchQuery.isEmpty
        ? _drinks
        : _drinks.where((drink) {
            final name = (drink['vietnamese_name'] ?? drink['name'] ?? '')
                .toString()
                .toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: WebDataTable<Map<String, dynamic>>(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Mô tả')),
          DataColumn(label: Text('Hydration')),
          DataColumn(label: Text('Thể tích')),
        ],
        rows: filteredDrinks,
        rowBuilder: (context, drink, index) {
          final hydration = _toDouble(drink['hydration_ratio']);
          return DataRow(
            cells: [
              DataCell(Text('${drink['drink_id'] ?? ''}')),
              DataCell(Text(
                drink['vietnamese_name'] ?? drink['name'] ?? 'N/A',
              )),
              DataCell(
                Text(
                  drink['description'] ?? 'Không có mô tả',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(Text('${(hydration * 100).toStringAsFixed(0)}%')),
              DataCell(Text('${drink['default_volume_ml'] ?? 250} ml')),
              DataCell(const SizedBox.shrink()),
            ],
          );
        },
        isLoading: _isLoading,
        currentPage: 1,
        totalPages: 1,
        totalItems: filteredDrinks.length,
        searchHint: 'Tìm kiếm đồ uống...',
        onSearch: (query) {
          setState(() => _searchQuery = query);
        },
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
