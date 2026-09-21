import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmApiServices {
  static const String baseUrl =
      'http://41.59.228.129:8087/api/v1';

  // ============================================================
  // GET TOKEN
  // ============================================================

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.trim().isEmpty) {
      throw Exception('User is not logged in');
    }

    return token;
  }

  // ============================================================
  // CREATE FARM
  // ============================================================

  static Future<Map<String, dynamic>> createFarm({
    required String name,
    required double acreage,
    required String plantingDate,
    required String farmType,
    required String geometry,
    required String region,
    required String district,
    required String ward,
    required String village,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms',
    );

    final requestBody = <String, dynamic>{
      'name': name.trim(),
      'acreage': acreage,
      'plantingDate': plantingDate.trim(),

      // IMPORTANT:
      // Backend enum value must remain unchanged.
      'farmType': farmType.trim().toUpperCase(),

      // PostGIS polygon in WKT format.
      // Example:
      // POLYGON((39.1 -6.8,39.2 -6.8,39.2 -6.9,39.1 -6.8))
      'geometry': geometry.trim(),

      'region': region.trim(),
      'district': district.trim(),
      'ward': ward.trim(),
      'village': village.trim(),
    };

    print('========================================');
    print('CREATE FARM URL: $uri');
    print(
      'CREATE FARM REQUEST: ${jsonEncode(requestBody)}',
    );
    print('========================================');

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(
          const Duration(seconds: 30),
        );

    print('========================================');
    print(
      'CREATE FARM STATUS: ${response.statusCode}',
    );
    print(
      'CREATE FARM RESPONSE: ${response.body}',
    );
    print('========================================');

    dynamic decoded;

    if (response.body.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(
          response.body,
        );
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (decoded is Map) {
        // Handle:
        //
        // {
        //   "data": {...}
        // }
        //
        // as well as a direct farm object.

        if (decoded['data'] is Map) {
          return Map<String, dynamic>.from(
            decoded['data'] as Map,
          );
        }

        return Map<String, dynamic>.from(
          decoded,
        );
      }

      return <String, dynamic>{};
    }

    String message =
        'Failed to create farm (${response.statusCode})';

    if (decoded is Map) {
      final serverMessage =
          decoded['message'] ??
          decoded['error'] ??
          decoded['detail'];

      if (serverMessage != null &&
          serverMessage
              .toString()
              .trim()
              .isNotEmpty) {
        message =
            serverMessage.toString();
      }
    } else if (response.body.trim().isNotEmpty) {
      message = response.body.trim();
    }

    throw FarmApiException(
      message: message,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  // ============================================================
  // GET MY FARMS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getMyFarms() async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/my',
    );

    final response = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 30),
        );

    print(
      'GET MY FARMS STATUS: ${response.statusCode}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(
        response.body,
      );

      // Direct array:
      //
      // [
      //   {...},
      //   {...}
      // ]

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item,
              ),
            )
            .toList();
      }

      // Wrapped response:
      //
      // {
      //   "data": [...]
      // }

      if (decoded is Map &&
          decoded['data'] is List) {
        return (decoded['data'] as List)
            .whereType<Map>()
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item,
              ),
            )
            .toList();
      }

      return [];
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(
        response.body,
      );
    } catch (_) {
      decoded = null;
    }

    String message =
        'Failed to load farms (${response.statusCode})';

    if (decoded is Map) {
      final serverMessage =
          decoded['message'] ??
          decoded['error'] ??
          decoded['detail'];

      if (serverMessage != null) {
        message =
            serverMessage.toString();
      }
    }

    throw FarmApiException(
      message: message,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  // ============================================================
  // GET FARM BY ID
  // ============================================================

  static Future<Map<String, dynamic>>
      getFarm(
    String farmId,
  ) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId',
    );

    final response = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 30),
        );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return {};
      }

      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is Map) {
        if (decoded['data'] is Map) {
          return Map<String, dynamic>.from(
            decoded['data'] as Map,
          );
        }

        return Map<String, dynamic>.from(
          decoded,
        );
      }

      return {};
    }

    throw FarmApiException(
      message:
          'Failed to load farm (${response.statusCode})',
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('token');
  }
}

// ================================================================
// API EXCEPTION
//
// This lets LocalDataService distinguish:
// - server rejected request
// from
// - device cannot reach server.
//
// A 400/401/403/500 must NOT automatically be called "offline".
// ================================================================

class FarmApiException implements Exception {
  final String message;
  final int statusCode;
  final String? responseBody;

  const FarmApiException({
    required this.message,
    required this.statusCode,
    this.responseBody,
  });

  @override
  String toString() {
    return message;
  }
}