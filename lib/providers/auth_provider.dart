import 'package:flutter/material.dart';

import '../services/api_services/api_services.dart';
import '../services/session_service.dart';

enum AuthStatus {
  checking,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.checking;

  Map<String, dynamic>? _currentUser;

  AuthStatus get status => _status;

  Map<String, dynamic>? get currentUser => _currentUser;

  bool get isChecking =>
      _status == AuthStatus.checking;

  bool get isAuthenticated =>
      _status == AuthStatus.authenticated;

  bool get isUnauthenticated =>
      _status == AuthStatus.unauthenticated;

  // ============================================================
  // CHECK SESSION
  // ============================================================

  Future<void> checkSession() async {
    _status = AuthStatus.checking;
    notifyListeners();

    try {
      final token = await SessionService.getToken();

      if (token == null || token.isEmpty) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      // Validate the existing token against backend.
      final user = await ApiServices.getCurrentUser();

      _currentUser = user;
      _status = AuthStatus.authenticated;

      notifyListeners();
    } catch (e) {
      debugPrint(
        'AUTH SESSION CHECK ERROR: $e',
      );

      await SessionService.clearSession();

      _currentUser = null;
      _status = AuthStatus.unauthenticated;

      notifyListeners();
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

Future<Map<String, dynamic>> login({
  required String username,
  required String password,
}) async {
  _status = AuthStatus.checking;
  notifyListeners();

  try {
    final result = await ApiServices.login(
      username: username,
      password: password,
    );

    final user = await ApiServices.getCurrentUser();

    _currentUser = user;
    _status = AuthStatus.authenticated;
    notifyListeners();

    debugPrint('LOGIN SUCCESS');
    debugPrint('CURRENT USER: $_currentUser');

    return result;
  } catch (e) {
    debugPrint('AUTH LOGIN ERROR: $e');

    await SessionService.clearSession();

    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();

    rethrow;
  }
}

  // ============================================================
  // SESSION EXPIRED
  // ============================================================

  Future<void> sessionExpired() async {
    await SessionService.clearSession();

    _currentUser = null;
    _status = AuthStatus.unauthenticated;

    notifyListeners();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await ApiServices.logout();

    _currentUser = null;
    _status = AuthStatus.unauthenticated;

    notifyListeners();
  }
}