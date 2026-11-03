import 'package:flutter/material.dart';
import '../helpers/di.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromStore();
  }

  void _loadThemeFromStore() {
    _isDarkMode = appData.read('isDarkMode') ?? false;
    notifyListeners();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await appData.write('isDarkMode', value);
    notifyListeners();
  }
}
