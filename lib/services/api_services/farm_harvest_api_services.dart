import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmHarvestApiServices {
  static const String baseUrl =
      'http://41.59.228.129:8087/api/v1';

  // ============================================================
  // TOKEN
  // ============================================================

  static Future<String> _getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token =
        prefs.getString('token');

    if (token == null ||
        token.trim().isEmpty) {
      throw Exception(
        'User is not logged in',
      );
    }

    return token;
  }

  // ============================================================
  // CREATE FARM HARVEST
  //
  // POST
  // /api/v1/farms/{farmId}/harvests
  // ============================================================

  static Future<Map<String, dynamic>>
      createHarvest({
    required String farmId,
    required String harvestDate,
    required int bucketCount,
    required double kgPerBucket,
    required double cost,
    String description = '',
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/harvests',
    );

    final requestBody = {
      'harvestDate': harvestDate,
      'bucketCount': bucketCount,
      'kgPerBucket': kgPerBucket,
      'cost': cost,
      'description': description,
    };

    debugPrint(
      'CREATE FARM HARVEST URL: $uri',
    );

    debugPrint(
      'CREATE FARM HARVEST REQUEST: '
      '${jsonEncode(requestBody)}',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type':
            'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer $token',
      },
      body: jsonEncode(
        requestBody,
      ),
    );

    debugPrint(
      'CREATE FARM HARVEST STATUS: '
      '${response.statusCode}',
    );

    debugPrint(
      'CREATE FARM HARVEST RESPONSE: '
      '${response.body}',
    );

    Map<String, dynamic> data = {};

    if (response.body.trim().isNotEmpty) {
      try {
        final decoded =
            jsonDecode(response.body);

        if (decoded is Map) {
          data =
              Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (_) {
        throw Exception(
          'Server returned an invalid response '
          '(${response.statusCode})',
        );
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Session expired. Please login again.',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        'You are not allowed to record '
        'a harvest for this farm.',
      );
    }

    throw Exception(
      data['message'] ??
          data['error'] ??
          'Failed to create farm harvest '
              '(${response.statusCode})',
    );
  }

  // ============================================================
  // GET FARM HARVESTS
  //
  // GET
  // /api/v1/farms/{farmId}/harvests
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getFarmHarvests({
    required String farmId,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/harvests',
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization':
            'Bearer $token',
      },
    );

    debugPrint(
      'GET FARM HARVESTS STATUS: '
      '${response.statusCode}',
    );

    debugPrint(
      'GET FARM HARVESTS RESPONSE: '
      '${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final decoded =
          jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map<Map<String, dynamic>>(
          (item) {
            return Map<String, dynamic>.from(
              item as Map,
            );
          },
        ).toList();
      }

      if (decoded is Map &&
          decoded['data'] is List) {
        return (decoded['data'] as List)
            .map<Map<String, dynamic>>(
          (item) {
            return Map<String, dynamic>.from(
              item as Map,
            );
          },
        ).toList();
      }

      return [];
    }

    throw Exception(
      'Failed to load farm harvests '
      '(${response.statusCode})',
    );
  }

  // ============================================================
  // GET MY FARM HARVESTS
  //
  // This requires backend:
  // GET /api/v1/harvests/my
  // ============================================================

 static Future<List<Map<String, dynamic>>>
    getMyHarvests() async {
  final token = await _getToken();

  final uri = Uri.parse(
    '$baseUrl/harvests/my',
  );

  final response = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Authorization':
          'Bearer $token',
    },
  );

  debugPrint(
    'GET MY HARVESTS STATUS: '
    '${response.statusCode}',
  );

  debugPrint(
    'GET MY HARVESTS RESPONSE: '
    '${response.body}',
  );

  if (response.statusCode >= 200 &&
      response.statusCode < 300) {
    if (response.body.trim().isEmpty) {
      return [];
    }

    final decoded =
        jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map<Map<String, dynamic>>(
        (item) {
          return Map<String, dynamic>.from(
            item as Map,
          );
        },
      ).toList();
    }

    if (decoded is Map &&
        decoded['data'] is List) {
      return (decoded['data'] as List)
          .map<Map<String, dynamic>>(
        (item) {
          return Map<String, dynamic>.from(
            item as Map,
          );
        },
      ).toList();
    }

    return [];
  }

  if (response.statusCode == 401) {
    throw Exception(
      'Session expired. Please login again.',
    );
  }

  throw Exception(
    'Failed to load farm harvests '
    '(${response.statusCode})',
  );
}
}