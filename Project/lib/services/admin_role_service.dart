import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminRoleService {
  static const String baseUrl = '${ApiConfig.baseUrl}/admin';
  static const String _tokenKey = 'auth_token'; // Same as AuthService

  // Lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Headers với token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============= ROLE QUERIES =============

  /// Lấy tất cả roles có trong hệ thống
  Future<List<Map<String, dynamic>>> getAllRoles() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/roles/all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['roles']);
      } else {
        throw Exception('Failed to get roles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting roles: $e');
    }
  }

  /// Lấy roles của admin hiện tại
  Future<List<String>> getMyRoles() async {
    try {
      final headers = await _getHeaders();
      debugPrint('DEBUG AdminRoleService: Getting my roles...');
      debugPrint('DEBUG AdminRoleService: Headers = $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/roles/my-roles'),
        headers: headers,
      );

      debugPrint('DEBUG AdminRoleService: Response status = ${response.statusCode}');
      debugPrint('DEBUG AdminRoleService: Response body = ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final roles = List<String>.from(data['roles']);
        debugPrint('DEBUG AdminRoleService: My roles = $roles');
        return roles;
      } else {
        debugPrint('DEBUG AdminRoleService: Failed with status ${response.statusCode}');
        throw Exception('Failed to get my roles: ${response.body}');
      }
    } catch (e) {
      debugPrint('DEBUG AdminRoleService: Exception = $e');
      throw Exception('Error getting my roles: $e');
    }
  }

  /// Lấy permission map của tất cả roles
  Future<Map<String, dynamic>> getRolePermissions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/roles/permissions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['permissions'];
      } else {
        throw Exception('Failed to get permissions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting permissions: $e');
    }
  }

  /// Lấy roles của một admin cụ thể (cần super_admin)
  Future<Map<String, dynamic>> getAdminRoles(int adminId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/roles/admins/$adminId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['admin'];
      } else if (response.statusCode == 403) {
        throw Exception('Chỉ super_admin mới có quyền này');
      } else {
        throw Exception('Failed to get admin roles: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting admin roles: $e');
    }
  }

  // ============= ROLE MANAGEMENT =============

  /// Gán role cho admin (cần super_admin)
  Future<Map<String, dynamic>> assignRole(int adminId, String roleName) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/roles/admins/$adminId/assign'),
        headers: headers,
        body: json.encode({'role_name': roleName}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['admin'];
      } else if (response.statusCode == 403) {
        throw Exception('Chỉ super_admin mới có quyền gán role');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Invalid request');
      } else {
        throw Exception('Failed to assign role: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error assigning role: $e');
    }
  }

  /// Gỡ role khỏi admin (cần super_admin)
  Future<Map<String, dynamic>> removeRole(int adminId, String roleName) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/roles/admins/$adminId/remove'),
        headers: headers,
        body: json.encode({'role_name': roleName}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['admin'];
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Chỉ super_admin mới có quyền gỡ role');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Invalid request');
      } else {
        throw Exception('Failed to remove role: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error removing role: $e');
    }
  }

  // ============= HELPER METHODS =============

  /// Check xem admin hiện tại có phải super_admin không
  Future<bool> isSuperAdmin() async {
    try {
      final roles = await getMyRoles();
      return roles.contains('super_admin');
    } catch (e) {
      return false;
    }
  }

  /// Check xem admin hiện tại có role cụ thể không
  Future<bool> hasRole(String roleName) async {
    try {
      final roles = await getMyRoles();
      return roles.contains(roleName);
    } catch (e) {
      return false;
    }
  }

  /// Lấy danh sách tất cả admins (từ user management API)
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admins'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['admins'] ?? []);
      } else {
        throw Exception('Failed to get admins: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting admins: $e');
    }
  }

  /// Get màu cho role badge
  static String getRoleColor(String roleName) {
    switch (roleName) {
      case 'super_admin':
        return '#FF4444'; // Red
      case 'user_manager':
        return '#4CAF50'; // Green
      case 'content_manager':
        return '#2196F3'; // Blue
      case 'analyst':
        return '#FF9800'; // Orange
      case 'support':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }

  /// Get icon cho role
  static String getRoleIcon(String roleName) {
    switch (roleName) {
      case 'super_admin':
        return '👑'; // Crown
      case 'user_manager':
        return '👥'; // Users
      case 'content_manager':
        return '📝'; // Content
      case 'analyst':
        return '📊'; // Analytics
      case 'support':
        return '🎧'; // Support
      default:
        return '🔑'; // Key
    }
  }

  /// Get mô tả cho role
  static String getRoleDescription(String roleName) {
    switch (roleName) {
      case 'super_admin':
        return 'Toàn quyền hệ thống';
      case 'user_manager':
        return 'Quản lý người dùng';
      case 'content_manager':
        return 'Quản lý nội dung (Foods, Nutrients)';
      case 'analyst':
        return 'Xem analytics và báo cáo';
      case 'support':
        return 'Hỗ trợ người dùng';
      default:
        return 'Unknown role';
    }
  }
}

