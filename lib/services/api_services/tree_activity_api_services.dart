import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TreeActivityApiServices {
  static const String baseUrl =
      'http://41.59.228.129:8087/api/v1';

  static Future<String> _getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not found',
      );
    }

    return token;
  }

  // ============================================================
  // GET ACTIVITIES OF ONE TREE
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getTreeActivities({
    required String farmId,
    required String blockId,
    required String treeId,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/'
      'blocks/$blockId/'
      'trees/$treeId/'
      'activities',
    );

    debugPrint(
      'GET TREE ACTIVITIES URL: $uri',
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint(
      'GET TREE ACTIVITIES STATUS: '
      '${response.statusCode}',
    );

    debugPrint(
      'GET TREE ACTIVITIES RESPONSE: '
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
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item as Map,
              ),
            )
            .toList();
      }

      if (decoded is Map &&
          decoded['data'] is List) {
        return (decoded['data'] as List)
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item as Map,
              ),
            )
            .toList();
      }

      throw Exception(
        'Invalid activities response',
      );
    }

    throw Exception(
      'Failed to load activities '
      '(${response.statusCode}): '
      '${response.body}',
    );
  }

  // ============================================================
  // CREATE ACTIVITY
  // ============================================================

  static Future<Map<String, dynamic>> createActivity({
  required String farmId,
  required String blockId,
  required String treeId,
  required String activityType,
  required String activityDate,
  String description = '',
  String status = 'COMPLETED',
  double cost = 0,
  String? harvestMethod,
  double? harvestedKg,
}) async {
  final token = await _getToken();

  final uri = Uri.parse(
    '$baseUrl/farms/$farmId/blocks/$blockId/trees/$treeId/activities',
  );

  final body = {
    'activityType': activityType,
    'activityDate': activityDate,
    'description': description,
    'status': status,
    'cost': cost,
    'harvestMethod': harvestMethod,
    'bucketCount': null,
    'kgPerBucket': null,
    'harvestedKg': harvestedKg,
  };

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  debugPrint(
    'CREATE ACTIVITY STATUS: ${response.statusCode}',
  );

  debugPrint(
    'CREATE ACTIVITY RESPONSE: ${response.body}',
  );

  if (response.statusCode >= 200 &&
      response.statusCode < 300) {
    if (response.body.isEmpty) {
      return {};
    }

    final decoded =
        jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception(
      'Invalid activity response.',
    );
  }

  throw Exception(
    'Unable to save activity '
    '(${response.statusCode}): '
    '${response.body}',
  );
}

  static Future<List<Map<String, dynamic>>>
    getMyActivities() async {
  final token = await _getToken();

  final uri = Uri.parse(
    '$baseUrl/activities/my',
  );

  debugPrint(
    'GET MY ACTIVITIES URL: $uri',
  );

  final response = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  debugPrint(
    'GET MY ACTIVITIES STATUS: '
    '${response.statusCode}',
  );

  debugPrint(
    'GET MY ACTIVITIES RESPONSE: '
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
          .map(
            (item) =>
                Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();
    }

    if (decoded is Map &&
        decoded['data'] is List) {
      return (decoded['data'] as List)
          .map(
            (item) =>
                Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();
    }

    throw Exception(
      'Invalid activities response',
    );
  }

  throw Exception(
    'Failed to load activities '
    '(${response.statusCode}): '
    '${response.body}',
  );
}

  // ============================================================
  // DELETE ACTIVITY
  // ============================================================

  static Future<void> deleteActivity({
    required String farmId,
    required String blockId,
    required String treeId,
    required String activityId,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/'
      'blocks/$blockId/'
      'trees/$treeId/'
      'activities/$activityId',
    );

    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to delete activity '
        '(${response.statusCode}): '
        '${response.body}',
      );
    }
  }
}