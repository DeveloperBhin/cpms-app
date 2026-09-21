import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TreeApiException implements Exception {
  final String message;
  final int? statusCode;

  const TreeApiException(
    this.message, {
    this.statusCode,
  });

  bool get isUnauthorized =>
      statusCode == 401 ||
      statusCode == 403;

  bool get isNotFound =>
      statusCode == 404;

  @override
  String toString() => message;
}

class TreeApiServices {
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
      throw const TreeApiException(
        'Your login session is not available.',
        statusCode: 401,
      );
    }

    return token.trim();
  }

  // ============================================================
  // HEADERS
  // ============================================================

  static Future<Map<String, String>>
      _headers({
    bool includeContentType = false,
  }) async {
    final token = await _getToken();

    return {
      'Accept': 'application/json',
      if (includeContentType)
        'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // HANDLE AUTHENTICATION ERROR
  // ============================================================

  static Future<void> _checkSession(
    http.Response response,
  ) async {
    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove('token');

      throw TreeApiException(
        'Your login session has expired. '
        'Please log in again.',
        statusCode: response.statusCode,
      );
    }
  }

  // ============================================================
  // CREATE TREE
  // ============================================================

  static Future<Map<String, dynamic>>
      createTree({
    required String farmId,
    required String blockId,
    required String variety,
    required int plantingYear,
    required String status,
    String? geometry,
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/$blockId/trees',
    );

    final body = <String, dynamic>{
      'variety': variety.trim(),
      'plantingYear': plantingYear,
      'status': status,
      'geometry': geometry?.trim(),
      'notes': notes?.trim(),

      if (latitude != null)
        'latitude': latitude,

      if (longitude != null)
        'longitude': longitude,
    };

    debugPrint(
      'CREATE TREE URL: $uri',
    );

    debugPrint(
      'CREATE TREE BODY: '
      '${jsonEncode(body)}',
    );

    try {
      final response =
          await http.post(
        uri,
        headers: await _headers(
          includeContentType: true,
        ),
        body: jsonEncode(body),
      );

      debugPrint(
        'CREATE TREE STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'CREATE TREE RESPONSE: '
        '${response.body}',
      );

      await _checkSession(response);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body
            .trim()
            .isEmpty) {
          return {};
        }

        final decoded =
            jsonDecode(response.body);

        if (decoded is Map) {
          return Map<String, dynamic>.from(
            decoded,
          );
        }

        throw const TreeApiException(
          'Invalid tree response from server.',
        );
      }

      throw TreeApiException(
        'Failed to create tree '
        '(${response.statusCode}): '
        '${response.body}',
        statusCode:
            response.statusCode,
      );
    } on SocketException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    } on http.ClientException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    }
  }

  // ============================================================
  // GET TREES BY BLOCK
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getTreesByBlock({
    required String farmId,
    required String blockId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/$blockId/trees',
    );

    debugPrint(
      'GET TREES URL: $uri',
    );

    try {
      final response =
          await http.get(
        uri,
        headers: await _headers(),
      );

      debugPrint(
        'GET TREES STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'GET TREES RESPONSE: '
        '${response.body}',
      );

      await _checkSession(response);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body
            .trim()
            .isEmpty) {
          return [];
        }

        final decoded =
            jsonDecode(response.body);

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

      throw TreeApiException(
        'Failed to load trees '
        '(${response.statusCode}): '
        '${response.body}',
        statusCode:
            response.statusCode,
      );
    } on SocketException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    } on http.ClientException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    }
  }

  // ============================================================
  // GET ONE TREE
  // ============================================================

  static Future<Map<String, dynamic>>
      getTree({
    required String farmId,
    required String blockId,
    required String treeId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/'
      '$blockId/trees/$treeId',
    );

    debugPrint(
      'GET TREE URL: $uri',
    );

    try {
      final response =
          await http.get(
        uri,
        headers: await _headers(),
      );

      debugPrint(
        'GET TREE STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'GET TREE RESPONSE: '
        '${response.body}',
      );

      await _checkSession(response);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body
            .trim()
            .isEmpty) {
          throw const TreeApiException(
            'Tree response was empty.',
          );
        }

        final decoded =
            jsonDecode(response.body);

        return _extractTree(decoded);
      }

      if (response.statusCode == 404) {
        throw const TreeApiException(
          'Tree not found.',
          statusCode: 404,
        );
      }

      throw TreeApiException(
        'Failed to load tree '
        '(${response.statusCode}): '
        '${response.body}',
        statusCode:
            response.statusCode,
      );
    } on SocketException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    } on http.ClientException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    }
  }

  // ============================================================
  // GET MY TREES
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getMyTrees() async {
    final uri =
        Uri.parse('$baseUrl/trees/my');

    debugPrint(
      'GET MY TREES URL: $uri',
    );

    try {
      final response =
          await http.get(
        uri,
        headers: await _headers(),
      );

      debugPrint(
        'GET MY TREES STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'GET MY TREES RESPONSE: '
        '${response.body}',
      );

      await _checkSession(response);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body
            .trim()
            .isEmpty) {
          return [];
        }

        final decoded =
            jsonDecode(response.body);

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

      throw TreeApiException(
        'Failed to load trees '
        '(${response.statusCode}): '
        '${response.body}',
        statusCode:
            response.statusCode,
      );
    } on SocketException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    } on http.ClientException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    }
  }

  // ============================================================
  // GET TREE BY BARCODE
  // ============================================================

  static Future<Map<String, dynamic>>
      getTreeByCode({
    required String treeCode,
  }) async {
    // Keep exactly what the scanner/manual input produced
    // except surrounding spaces.
    final code =
        treeCode.trim();

    if (code.isEmpty) {
      throw const TreeApiException(
        'Tree code cannot be empty.',
      );
    }

    final encodedCode =
        Uri.encodeComponent(code);

    final uri = Uri.parse(
      '$baseUrl/trees/code/$encodedCode',
    );

    debugPrint(
      '================================',
    );

    debugPrint(
      'TREE BARCODE LOOKUP',
    );

    debugPrint(
      'BARCODE: [$code]',
    );

    debugPrint(
      'BARCODE LENGTH: ${code.length}',
    );

    debugPrint(
      'GET TREE BY CODE URL: $uri',
    );

    try {
      final response =
          await http.get(
        uri,
        headers: await _headers(),
      );

      debugPrint(
        'GET TREE BY CODE STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'GET TREE BY CODE RESPONSE: '
        '${response.body}',
      );

      debugPrint(
        '================================',
      );

      // Authentication failure is NOT tree-not-found.
      await _checkSession(response);

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        if (response.body
            .trim()
            .isEmpty) {
          throw const TreeApiException(
            'Tree response was empty.',
          );
        }

        final decoded =
            jsonDecode(response.body);

        final tree =
            _extractTree(decoded);

        debugPrint(
          'TREE FOUND: $tree',
        );

        return tree;
      }

      // --------------------------------------------------------
      // REAL 404
      // --------------------------------------------------------

      if (response.statusCode == 404) {
        throw TreeApiException(
          'Tree with code $code was not found.',
          statusCode: 404,
        );
      }

      // --------------------------------------------------------
      // OTHER SERVER ERROR
      // --------------------------------------------------------

      throw TreeApiException(
        'Failed to find tree '
        '(${response.statusCode}): '
        '${response.body}',
        statusCode:
            response.statusCode,
      );
    } on SocketException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    } on http.ClientException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    } on FormatException {
      throw const TreeApiException(
        'The server returned an invalid response.',
      );
    }
  }

  // ============================================================
  // EXTRACT TREE FROM API RESPONSE
  // ============================================================

  static Map<String, dynamic> _extractTree(
    dynamic decoded,
  ) {
    if (decoded is! Map) {
      throw const TreeApiException(
        'Invalid tree response from server.',
      );
    }

    final map =
        Map<String, dynamic>.from(
      decoded,
    );

    // API may return:
    //
    // {
    //   "id": ...
    // }
    //
    // OR:
    //
    // {
    //   "data": {
    //      "id": ...
    //   }
    // }

    if (map['data'] is Map) {
      return Map<String, dynamic>.from(
        map['data'] as Map,
      );
    }

    return map;
  }

  // ============================================================
  // DELETE TREE
  // ============================================================

  static Future<void> deleteTree({
    required String farmId,
    required String blockId,
    required String treeId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/farms/$farmId/blocks/'
      '$blockId/trees/$treeId',
    );

    debugPrint(
      'DELETE TREE URL: $uri',
    );

    try {
      final response =
          await http.delete(
        uri,
        headers: await _headers(),
      );

      debugPrint(
        'DELETE TREE STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'DELETE TREE RESPONSE: '
        '${response.body}',
      );

      await _checkSession(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw TreeApiException(
          'Failed to delete tree '
          '(${response.statusCode}): '
          '${response.body}',
          statusCode:
              response.statusCode,
        );
      }
    } on SocketException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    } on http.ClientException {
      throw const TreeApiException(
        'Unable to connect to the server.',
      );
    }
  }
}