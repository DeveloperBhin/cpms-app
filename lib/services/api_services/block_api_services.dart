import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BlockApiServices {
  // Use the same baseUrl that your FarmApiServices uses.
  static const String baseUrl =
      'http://41.59.228.129:8087/api/v1';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('User is not logged in');
    }

    return token;
  }

  // ============================================================
  // GET BLOCKS BY FARM
  // ============================================================

  static Future<List<Map<String, dynamic>>> getBlocksByFarm(
    String farmId,
  ) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks',
    );

    debugPrint('GET BLOCKS URL: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint(
      'GET BLOCKS STATUS: ${response.statusCode}',
    );

    debugPrint(
      'GET BLOCKS RESPONSE: ${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map(
              (item) => Map<String, dynamic>.from(
                item as Map,
              ),
            )
            .toList();
      }

      if (decoded is Map &&
          decoded['data'] is List) {
        return (decoded['data'] as List)
            .map(
              (item) => Map<String, dynamic>.from(
                item as Map,
              ),
            )
            .toList();
      }

      return [];
    }

    throw Exception(
      'Failed to load blocks (${response.statusCode}): '
      '${response.body}',
    );
  }

  // ============================================================
  // GET SINGLE BLOCK
  // ============================================================

  static Future<Map<String, dynamic>> getBlock({
    required String farmId,
    required String blockId,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/$blockId',
    );

    debugPrint('GET BLOCK URL: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint(
      'GET BLOCK STATUS: ${response.statusCode}',
    );

    debugPrint(
      'GET BLOCK RESPONSE: ${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
    }

    throw Exception(
      'Failed to load block (${response.statusCode}): '
      '${response.body}',
    );
  }

  // ============================================================
  // CREATE BLOCK
  // ============================================================

  static Future<Map<String, dynamic>> createBlock({
    required String farmId,
    required String name,
    required double size,
    String? variety,
    int? treeCount,
    String? description,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks',
    );

    final body = {
      'name': name.trim(),
      'size': size,
      'variety': variety?.trim(),
      'treeCount': treeCount,
      'description': description?.trim(),
    };

    debugPrint('CREATE BLOCK URL: $uri');
    debugPrint(
      'CREATE BLOCK BODY: ${jsonEncode(body)}',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    debugPrint(
      'CREATE BLOCK STATUS: ${response.statusCode}',
    );

    debugPrint(
      'CREATE BLOCK RESPONSE: ${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
    }

    throw Exception(
      'Failed to create block (${response.statusCode}): '
      '${response.body}',
    );
  }

  // ============================================================
  // UPDATE BLOCK
  // ============================================================

  static Future<Map<String, dynamic>> updateBlock({
    required String farmId,
    required String blockId,
    required String name,
    required double size,
    String? variety,
    int? treeCount,
    String? description,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/$blockId',
    );

    final body = {
      'name': name.trim(),
      'size': size,
      'variety': variety?.trim(),
      'treeCount': treeCount,
      'description': description?.trim(),
    };

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    debugPrint(
      'UPDATE BLOCK STATUS: ${response.statusCode}',
    );

    debugPrint(
      'UPDATE BLOCK RESPONSE: ${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
    }

    throw Exception(
      'Failed to update block (${response.statusCode}): '
      '${response.body}',
    );
  }

  // ============================================================
  // DELETE BLOCK
  // ============================================================

  static Future<void> deleteBlock({
    required String farmId,
    required String blockId,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/$blockId',
    );

    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint(
      'DELETE BLOCK STATUS: ${response.statusCode}',
    );

    debugPrint(
      'DELETE BLOCK RESPONSE: ${response.body}',
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Failed to delete block (${response.statusCode}): '
        '${response.body}',
      );
    }
  }
}