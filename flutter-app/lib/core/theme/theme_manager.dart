import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static ThemeManager get instance => _instance;

  bool _isDarkMode = false;
  double _fontSize = 16.0;
  String _language = '한국어';

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  String get language => _language;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// 초기 설정 로드
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _fontSize = prefs.getDouble('font_size') ?? 16.0;
      _language = prefs.getString('language') ?? '한국어';
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load theme settings: $e');
    }
  }

  /// 다크모드 토글
  Future<void> toggleDarkMode(bool value) async {
    try {
      _isDarkMode = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', value);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save dark mode setting: $e');
    }
  }

  /// 폰트 크기 변경
  Future<void> setFontSize(double size) async {
    try {
      _fontSize = size;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_size', size);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save font size setting: $e');
    }
  }

  /// 언어 변경
  Future<void> setLanguage(String language) async {
    try {
      _language = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save language setting: $e');
    }
  }

  /// 모든 설정 저장
  Future<void> saveAllSettings({
    bool? darkMode,
    double? fontSize,
    String? language,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (darkMode != null) {
        _isDarkMode = darkMode;
        await prefs.setBool('dark_mode', darkMode);
      }

      if (fontSize != null) {
        _fontSize = fontSize;
        await prefs.setDouble('font_size', fontSize);
      }

      if (language != null) {
        _language = language;
        await prefs.setString('language', language);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }
}
