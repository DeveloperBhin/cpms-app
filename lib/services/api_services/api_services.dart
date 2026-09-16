import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
  // Android emulator:
  // static const String baseUrl = 'http://10.0.2.2:8080/api';

  // For Windows desktop:
  // static const String baseUrl = 'http://localhost:8080/api';
  static const String baseUrl = 'http://41.59.228.129:8087/api/v1';

  // =========================
  // REGISTER
  // =========================

static Future<Map<String, dynamic>> register({
  required String fullName,
  required String username,
  required String region,
  required String district,
  required String ward,
  required String village,
  required String phoneNumber,
  required String password,
}) async {
  final uri = Uri.parse('$baseUrl/auth/register');

  final requestBody = {
    'fullName': fullName,
    'username': username,
    'region': region,
    'district': district,
    'ward': ward,
    'village': village,
    'phoneNumber': phoneNumber,
    'password': password,
  };

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('REGISTER URL: $uri');
    print('REGISTER REQUEST: ${jsonEncode(requestBody)}');
    print('REGISTER STATUS: ${response.statusCode}');
    print('REGISTER RESPONSE: ${response.body}');

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
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

    throw Exception(
      data['message'] ??
          data['error'] ??
          'Registration failed (${response.statusCode})',
    );
  } on http.ClientException catch (e) {
    throw Exception(
      'Unable to connect to the server: ${e.message}',
    );
  } on SocketException {
    throw Exception(
      'Unable to connect to the server. Check your internet connection.',
    );
  } catch (e) {
    if (e is Exception) {
      rethrow;
    }

    throw Exception('Registration failed');
  }
}

  // =========================
  // LOGIN
  // =========================

// =========================
// LOGIN
// =========================

static Future<Map<String, dynamic>> login({
  required String username,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'username': username,
      'password': password,
    }),
  );

  Map<String, dynamic> responseData = {};

  if (response.body.isNotEmpty) {
    responseData =
        jsonDecode(response.body) as Map<String, dynamic>;
  }

  if (response.statusCode >= 200 &&
      response.statusCode < 300) {

    final data = responseData['data'];
    print('LOGIN FULL RESPONSE: $responseData');
    print('LOGIN DATA: $data');

    if (data == null || data is! Map) {
      throw Exception(
        'Invalid login response from server',
      );
    }

    final token = data['token'];

    if (token == null ||
        token.toString().isEmpty) {
      throw Exception(
        'Token not returned by server',
      );
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'token',
      token.toString(),
    );

    return responseData;
  }

  throw Exception(
    responseData['message'] ??
        'Login failed (${response.statusCode})',
  );
}

  // =========================
  // CURRENT USER
  // =========================

  static Future<Map<String, dynamic>>
      getCurrentUser() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in',
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Failed to load user profile',
    );
  }

  // =========================
  // UPLOAD FILES
  // =========================

  static Future<Map<String, dynamic>>
      uploadFiles(
    List<PlatformFile> files,
  ) async {

    if (files.isEmpty) {
      throw Exception(
        'No files selected',
      );
    }

    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in',
      );
    }

    final uri = Uri.parse(
      '$baseUrl/uploads',
    );

    final request =
        http.MultipartRequest(
      'POST',
      uri,
    );

    // Authentication
    request.headers['Authorization'] =
        'Bearer $token';

    // Add selected files
    for (final file in files) {

      if (file.path == null) {
        continue;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path!,
          filename: file.name,
        ),
      );
    }

    if (request.files.isEmpty) {
      throw Exception(
        'No valid files selected',
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        throw Exception(
          'Invalid response from server',
        );
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'File upload failed '
          '(${response.statusCode})',
    );
  }

  // =========================
  // GET MY UPLOADS
  // =========================

  static Future<Map<String, dynamic>>
      getMyUploads() async {

    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in',
      );
    }

    final response = await http.get(
      Uri.parse('$baseUrl/uploads'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Failed to load uploads',
    );
  }

  // =========================
  // DELETE UPLOAD
  // =========================

  static Future<Map<String, dynamic>>
      deleteUpload(int id) async {

    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'User is not logged in',
      );
    }

    final response = await http.delete(
      Uri.parse(
        '$baseUrl/uploads/$id',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Failed to delete upload',
    );
  }

  // =========================
  // LOGOUT
  // =========================

  static Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('token');
  }
}