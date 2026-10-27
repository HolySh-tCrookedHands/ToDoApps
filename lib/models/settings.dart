import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String colorKey = 'main_color';
  static const String fontKey = 'font_family';
  static const String fontSizeKey = 'font_size';
  static const String darkModeKey = 'dark_mode';

  static const Map<String, Color> colors = {
    'Белый': Colors.white,
    'Чёрный': Colors.black,
    'Жёлтый': Colors.yellow,
    'Красный': Colors.red,
    'Серый': Colors.grey,
    'Серо-синий': Colors.blueGrey,
    'Синий': Colors.blue,
    'Зелёный': Colors.green,
  };

  static const List<String> fonts = [
    'Roboto',
    'Arial',
    'Times New Roman',
    'Courier New',
    'Georgia',
  ];

  static const List<double> fontSizes = [
    12,
    14,
    16,
    18,
    20,
    24,
  ];

  String selectedColor = colors.keys.first;
  String selectedFont = fonts.first;
  double selectedFontSize = 16;

  bool isDarkMode = false;

  Color get color => colors[selectedColor]!;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedColor = prefs.getString(colorKey);
    final savedFont = prefs.getString(fontKey);
    final savedFontSize = prefs.getDouble(fontSizeKey);
    final savedDarkMode = prefs.getBool(darkModeKey);

    if (
      savedColor != null &&
      colors.containsKey(savedColor)
    ) {
      selectedColor = savedColor;
    }

    if (
      savedFont != null &&
      fonts.contains(savedFont)
    ) {
      selectedFont = savedFont;
    }

    if (
      savedFontSize != null &&
      fontSizes.contains(savedFontSize)
    ) {
      selectedFontSize = savedFontSize;
    }

    if (savedDarkMode != null) {
      isDarkMode = savedDarkMode;
    }

    notifyListeners();
  }

  Future<void> setColor(String value) async {
    selectedColor = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(colorKey, value);

    notifyListeners();
  }

  Future<void> setFont(String value) async {
    selectedFont = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(fontKey, value);

    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    selectedFontSize = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(fontSizeKey, value);

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, value);

    notifyListeners();
  }
}
