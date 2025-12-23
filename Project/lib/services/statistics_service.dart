import 'dart:convert';
import '../config/api_config.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';

class StatisticsService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: ApiConfig.baseUrl,
  );

  static Future<Map<String, dynamic>> getMealPeriodSummary({
    String? date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/meal-history/period-summary?date=$targetDate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('[StatisticsService] Received data: ${data.keys}');
        debugPrint(
          '[StatisticsService] Periods count: ${(data['periods'] as List?)?.length ?? 0}',
        );
        if (data['periods'] != null) {
          final periods = data['periods'] as List;
          for (var period in periods) {
            debugPrint(
              '[StatisticsService] Period: ${period['key']} - ${period['label']} - entries: ${(period['entries'] as List?)?.length ?? 0}',
            );
          }
        }
        return data;
      }

      debugPrint(
        '[StatisticsService] Error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to fetch statistics');
    } catch (e) {
      debugPrint('[StatisticsService] getMealPeriodSummary error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getMealHistory({String? date}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/meal-history?date=$targetDate&limit=100'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      }

      debugPrint(
        '[StatisticsService] Error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to fetch meal history');
    } catch (e) {
      debugPrint('[StatisticsService] getMealHistory error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getWaterTimeline({String? date}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');
      final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/water/timeline?date=$targetDate'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['timeline'] as Map<String, dynamic>? ?? {};
      }
      debugPrint(
        '[StatisticsService] Water timeline error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to fetch water timeline');
    } catch (e) {
      debugPrint('[StatisticsService] getWaterTimeline error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getWaterPeriodSummary({
    String? date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/water/period-summary?date=$targetDate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('[StatisticsService] Water period data: ${data.keys}');
        debugPrint(
          '[StatisticsService] Water periods count: ${(data['periods'] as List?)?.length ?? 0}',
        );
        return data;
      }

      debugPrint(
        '[StatisticsService] Water period error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to fetch water period summary');
    } catch (e) {
      debugPrint('[StatisticsService] getWaterPeriodSummary error: $e');
      rethrow;
    }
  }
}
