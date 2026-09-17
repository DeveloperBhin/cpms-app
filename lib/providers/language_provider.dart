import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _locale = const Locale('sw');

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  bool get isSwahili => _locale.languageCode == 'sw';

  bool get isEnglish => _locale.languageCode == 'en';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage == 'sw' || savedLanguage == 'en') {
      _locale = Locale(savedLanguage!);
    }

    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'sw' && languageCode != 'en') {
      return;
    }

    if (_locale.languageCode == languageCode) {
      return;
    }

    _locale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _languageKey,
      languageCode,
    );

    notifyListeners();
  }
}