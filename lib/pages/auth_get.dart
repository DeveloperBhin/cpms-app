import 'package:flutter/material.dart';

import '../services/api_services/api_services.dart';
import '../services/session_service.dart';

import 'login_page.dart';
import 'main_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checkingSession = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final token = await SessionService.getToken();

      if (token == null) {
        if (!mounted) return;

        setState(() {
          _authenticated = false;
          _checkingSession = false;
        });

        return;
      }

      // Validate token with backend.
      await ApiServices.getCurrentUser();

      if (!mounted) return;

      setState(() {
        _authenticated = true;
        _checkingSession = false;
      });
    } catch (e) {
      debugPrint('SESSION CHECK ERROR: $e');

      await SessionService.clearSession();

      if (!mounted) return;

      setState(() {
        _authenticated = false;
        _checkingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        backgroundColor: Color(0xFF087A2F),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (!_authenticated) {
      return const LoginPage();
    }

    return const MainPage();
  }
}