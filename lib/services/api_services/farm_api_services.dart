import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmApiServices {
  // Android emulator:
  // static const String baseUrl = 'http://10.0.2.2:8080/api';

  // For Windows desktop:
  // static const String baseUrl = 'http://localhost:8080/api';
  static const String baseUrl = 'http://41.59.228.129:8087/api/v1';

  // =========================
  // REGISTER
  // =========================

  // =========================
  // CREATE FARM
  // =========================

  static Future<Map<String, dynamic>> createFarm({
    required String name,
    // required int farmerId,
    required double acreage,
    required String plantingDate,
    required String farmType,
    required String geometry,
    required String region,
    required String district,
    required String ward,
    required String village,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('User is not logged in');
    }

    final uri = Uri.parse('$baseUrl/farms');

    final requestBody = {
      'name': name,
      // 'farmerId': farmerId,
      'acreage': acreage,
      'plantingDate': plantingDate,
      'farmType': farmType,
      'geometry': geometry,
      'region': region,
      'district': district,
      'ward': ward,
      'village': village,
    };

    print('CREATE FARM URL: $uri');
    print('CREATE FARM REQUEST: ${jsonEncode(requestBody)}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print('CREATE FARM STATUS: ${response.statusCode}');
    print('CREATE FARM RESPONSE: ${response.body}');

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        throw Exception(
          'Server returned an invalid response (${response.statusCode})',
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ??
          data['error'] ??
          'Failed to create farm (${response.statusCode})',
    );
  }
  // =========================
  // LOGIN
  // =========================

  // =========================
  // DELETE UPLOAD
  // =========================

  // =========================
  // LOGOUT
  // =========================

  static Future<List<Map<String, dynamic>>> getMyFarms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('User is not logged in');
    }

    final uri = Uri.parse('$baseUrl/farms/my');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // debugPrint('GET MY FARMS STATUS: ${response.statusCode}');
    // debugPrint('GET MY FARMS RESPONSE: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      // In case your backend later wraps responses in ApiResponse.
      if (decoded is Map && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      return [];
    }

    throw Exception('Failed to load farms (${response.statusCode})');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
  }
}
