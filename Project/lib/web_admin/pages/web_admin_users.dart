import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class WebAdminUsers extends StatefulWidget {
  const WebAdminUsers({super.key});

  @override
  State<WebAdminUsers> createState() => _WebAdminUsersState();
}

class _WebAdminUsersState extends State<WebAdminUsers> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  String _searchQuery = '';
  bool _hasUnblockBadge = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _checkUnblockRequests();
  }

  Future<void> _loadUsers({int page = 1, String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/admin/users?page=$page&limit=20${search.isNotEmpty ? '&search=$search' : ''}',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = data['users'] ?? [];
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

  Future<void> _checkUnblockRequests() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/unblock-requests?status=pending'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final requests = data['requests'] ?? [];
        setState(() {
          _hasUnblockBadge = requests.isNotEmpty;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _handleSearch(String query) async {
    _searchQuery = query;
    await _loadUsers(page: 1, search: query);
  }

  Future<void> _blockUser(int userId, String? reason) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId/block'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'reason': reason ?? ''}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã chặn người dùng')),
          );
        }
        _loadUsers(page: _currentPage, search: _searchQuery);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chặn thất bại')),
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

  Future<void> _unblockUser(int userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId/unblock'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'admin_response': 'Manual unblocked'}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã gỡ chặn người dùng')),
          );
        }
        _loadUsers(page: _currentPage, search: _searchQuery);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gỡ chặn thất bại')),
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

  Future<void> _showBlockDialog(int userId) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chặn người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn có chắc chắn muốn chặn người dùng này?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do chặn (tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chặn'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _blockUser(userId, reasonController.text);
    }
  }

  Future<void> _showUnblockRequests() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/unblock-requests?status=pending'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final requests =
            List<Map<String, dynamic>>.from(data['requests'] ?? []);

        setState(() => _hasUnblockBadge = false);

        if (requests.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không có yêu cầu gỡ chặn nào')),
            );
          }
          return;
        }

        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => _UnblockRequestsDialog(
              requests: requests,
              onDecision: (requestId, userId, approved) async {
                await _decideUnblockRequest(requestId, approved);
                _loadUsers(page: _currentPage, search: _searchQuery);
              },
            ),
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

  Future<void> _decideUnblockRequest(int requestId, bool approved) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/admin/unblock-requests/$requestId/decide'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'decision': approved ? 'approve' : 'reject',
          'admin_response': approved ? 'Approved' : 'Rejected',
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  approved ? 'Đã chấp nhận yêu cầu' : 'Đã từ chối yêu cầu'),
            ),
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

  Future<void> _showUserDetails(int userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => _UserDetailsDialog(
              userDetails: data,
              onViewAnalytics: () {
                Navigator.pop(context);
                // Navigate to analytics screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _UserAnalyticsScreen(userId: userId),
                  ),
                );
              },
            ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: WebDataTable<Map<String, dynamic>>(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Người dùng')),
          DataColumn(label: Text('Giới tính')),
          DataColumn(label: Text('Ngày')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: _users.cast<Map<String, dynamic>>(),
        rowBuilder: (context, user, index) {
          final isBlocked = user['is_blocked'] == true;
          final userName = user['full_name'] ?? user['username'] ?? 'N/A';

          return DataRow(
            cells: [
              DataCell(
                Text(
                  '${user['user_id'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  user['gender'] ?? 'N/A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  user['created_at']?.toString().split('T')[0] ?? 'N/A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  isBlocked ? 'Chặn' : 'OK',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isBlocked ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _showUserDetails(user['user_id']),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.visibility, size: 16),
                      ),
                    ),
                    if (!isBlocked)
                      InkWell(
                        onTap: () => _showBlockDialog(user['user_id']),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.block, size: 16, color: Colors.red),
                        ),
                      )
                    else
                      InkWell(
                        onTap: () => _unblockUser(user['user_id']),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.lock_open,
                              size: 16, color: Colors.green),
                        ),
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
        onPageChanged: (page) => _loadUsers(page: page, search: _searchQuery),
        searchHint: 'Tìm kiếm người dùng...',
        onSearch: _handleSearch,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _showUnblockRequests,
                tooltip: 'Yêu cầu gỡ chặn',
              ),
              if (_hasUnblockBadge)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> userDetails;
  final VoidCallback onViewAnalytics;

  const _UserDetailsDialog({
    required this.userDetails,
    required this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final user = userDetails['user'] ?? {};
    final recentMeals = userDetails['recentMeals'] ?? [];
    final recentSummaries = userDetails['recentSummaries'] ?? [];

    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi tiết người dùng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Thông tin cá nhân',
                      [
                        _buildDetailRow(
                            'ID', user['user_id']?.toString() ?? 'N/A'),
                        _buildDetailRow('Tên', user['full_name'] ?? 'N/A'),
                        _buildDetailRow('Email', user['email'] ?? 'N/A'),
                        _buildDetailRow(
                            'Tuổi', user['age']?.toString() ?? 'N/A'),
                        _buildDetailRow('Giới tính', user['gender'] ?? 'N/A'),
                        _buildDetailRow(
                            'Chiều cao', '${user['height_cm'] ?? 0} cm'),
                        _buildDetailRow(
                            'Cân nặng', '${user['weight_kg'] ?? 0} kg'),
                        _buildDetailRow(
                            'Ngày tạo',
                            user['created_at']?.toString().split('T')[0] ??
                                'N/A'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Mục tiêu',
                      [
                        _buildDetailRow(
                            'Loại chế độ', user['diet_type'] ?? 'N/A'),
                        _buildDetailRow('Mục tiêu', user['goal_type'] ?? 'N/A'),
                        _buildDetailRow('Calo mục tiêu',
                            '${user['daily_calorie_target'] ?? 0} kcal'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Bữa ăn gần đây',
                      recentMeals.isEmpty
                          ? [const Text('Chưa có bữa ăn nào')]
                          : recentMeals.map<Widget>((meal) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '${meal['meal_date']} - ${meal['meal_type']}: ${meal['item_count']} món, ${meal['total_calories']} kcal',
                                ),
                              );
                            }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onViewAnalytics,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Xem Analytics & Hoạt động'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _UnblockRequestsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final Function(int requestId, int userId, bool approved) onDecision;

  const _UnblockRequestsDialog({
    required this.requests,
    required this.onDecision,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yêu cầu gỡ chặn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(request['email'] ?? 'N/A'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lý do: ${request['reason'] ?? 'N/A'}'),
                          Text(
                              'Ngày: ${request['created_at']?.toString().split('T')[0] ?? 'N/A'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              onDecision(
                                request['request_id'],
                                request['user_id'],
                                false,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Từ chối'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              onDecision(
                                request['request_id'],
                                request['user_id'],
                                true,
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Chấp nhận'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAnalyticsScreen extends StatefulWidget {
  final int userId;

  const _UserAnalyticsScreen({required this.userId});

  @override
  State<_UserAnalyticsScreen> createState() => _UserAnalyticsScreenState();
}

class _UserAnalyticsScreenState extends State<_UserAnalyticsScreen> {
  Map<String, dynamic>? analytics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/admin/users/${widget.userId}/activity/analytics?period=7d'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          analytics = data['analytics'] ?? data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics: User ${widget.userId}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : analytics == null || (analytics!['totalActivities'] ?? 0) == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Không có dữ liệu',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Người dùng chưa có hoạt động nào trong 7 ngày qua',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng hoạt động: ${analytics!['totalActivities'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Điểm tương tác: ${analytics!['engagementScore'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (analytics!['actionBreakdown'] != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Phân loại hoạt động',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...(analytics!['actionBreakdown'] as List)
                                    .map((action) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(action['action'] ?? 'N/A'),
                                        Text(
                                          '${action['count'] ?? 0} lần',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
