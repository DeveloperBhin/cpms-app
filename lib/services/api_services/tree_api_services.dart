import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TreeApiServices {
  // IMPORTANT:
  // Use exactly the same baseUrl as FarmApiServices
  // and BlockApiServices.
  static const String baseUrl = 'http://41.59.228.129:8087/api/v1';

  // ============================================================
  // TOKEN
  // ============================================================

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('User is not logged in');
    }

    return token;
  }

  // ============================================================
  // CREATE TREE
  // ============================================================

  static Future<Map<String, dynamic>> createTree({
    required String farmId,
    required String blockId,
    required String variety,
    required int plantingYear,
    required String status,
    String? geometry,
    String? notes,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse('$baseUrl/farms/$farmId/blocks/$blockId/trees');

    final body = <String, dynamic>{
      'variety': variety.trim(),
      'plantingYear': plantingYear,
      'status': status,
      'geometry': geometry?.trim(),
      'notes': notes?.trim(),
    };

    debugPrint('CREATE TREE URL: $uri');
    debugPrint('CREATE TREE BODY: ${jsonEncode(body)}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    debugPrint('CREATE TREE STATUS: ${response.statusCode}');

    debugPrint('CREATE TREE RESPONSE: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return {};
      }

      final decoded = jsonDecode(response.body);

      return Map<String, dynamic>.from(decoded as Map);
    }

    throw Exception(
      'Failed to create tree '
      '(${response.statusCode}): ${response.body}',
    );
  }

  // ============================================================
  // GET TREES BY BLOCK
  // ============================================================

  static Future<List<Map<String, dynamic>>> getTreesByBlock({
    required String farmId,
    required String blockId,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse('$baseUrl/farms/$farmId/blocks/$blockId/trees');

    debugPrint('GET TREES URL: $uri');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('GET TREES STATUS: ${response.statusCode}');

    debugPrint('GET TREES RESPONSE: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      if (decoded is Map && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      return [];
    }

    throw Exception(
      'Failed to load trees '
      '(${response.statusCode}): ${response.body}',
    );
  }

  // ============================================================
  // GET ONE TREE
  // ============================================================

  static Future<Map<String, dynamic>> getTree({
    required String farmId,
    required String blockId,
    required String treeId,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/$blockId/trees/$treeId',
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('GET TREE STATUS: ${response.statusCode}');

    debugPrint('GET TREE RESPONSE: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    }

    throw Exception(
      'Failed to load tree '
      '(${response.statusCode}): ${response.body}',
    );
  }

  static Future<List<Map<String, dynamic>>> getMyTrees() async {
    final token = await _getToken();

    final uri = Uri.parse('$baseUrl/trees/my');

    debugPrint('GET MY TREES URL: $uri');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('GET MY TREES STATUS: ${response.statusCode}');

    debugPrint('GET MY TREES RESPONSE: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      if (decoded is Map && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      return [];
    }

    throw Exception(
      'Failed to load trees '
      '(${response.statusCode}): '
      '${response.body}',
    );
  }

  static Future<Map<String, dynamic>> getTreeByCode({
    required String treeCode,
  }) async {
    final token = await _getToken();

    final code = treeCode.trim().toUpperCase();

    final uri = Uri.parse('$baseUrl/trees/code/${Uri.encodeComponent(code)}');

    debugPrint('GET TREE BY CODE URL: $uri');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('GET TREE BY CODE STATUS: ${response.statusCode}');

    debugPrint('GET TREE BY CODE RESPONSE: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        throw Exception('Tree response was empty');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw Exception('Invalid tree response');
    }

    if (response.statusCode == 404) {
      throw Exception('Tree not found');
    }

    throw Exception(
      'Failed to find tree '
      '(${response.statusCode}): '
      '${response.body}',
    );
  }

  // ============================================================
  // DELETE TREE
  // ============================================================

  static Future<void> deleteTree({
    required String farmId,
    required String blockId,
    required String treeId,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/$blockId/trees/$treeId',
    );

    final response = await http.delete(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('DELETE TREE STATUS: ${response.statusCode}');

    debugPrint('DELETE TREE RESPONSE: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to delete tree '
        '(${response.statusCode}): ${response.body}',
      );
    }
  }
}
