import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleThemeService {
  static bool _isDarkMode = false;
  static SharedPreferences? _prefs;
  static ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

  static bool get isDarkMode => _isDarkMode;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
    isDarkModeNotifier.value = _isDarkMode;
  }

  static Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool('isDarkMode', _isDarkMode);
    isDarkModeNotifier.value = _isDarkMode;
  }

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    primaryColor: Color.fromARGB(255, 4, 23, 53), // Professional navy blue
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 4, 23, 53),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Color(0xFFE9EEF8),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 4, 23, 53),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: Color.fromARGB(255, 4, 23, 53),
      secondary: Color(0xFF0F4BBF),
      background: Colors.black,
      surface: Colors.white,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    primaryColor: Color(0xFF071033), // Deep navy-black
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF071033),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(0xFF0E1624),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Color(0xFF0A1220),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 4, 23, 53),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color.fromARGB(255, 4, 23, 53),
      secondary: Color(0xFF0F4BBF),
      surface: Color(0xFF0E1624),
      background: Colors.black,
    ),
  );
}
