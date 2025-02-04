import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFED1C24);  // A nice blue shade
  static const Color secondaryColor = Color(0xFFFF6B6B);  // A coral red shade
  static const Color backgroundColor = Color(0xFFF5F5F5);  // Light grey background
  static const Color textPrimaryColor = Color(0xFF2D3142);  // Dark text color
  static const Color textSecondaryColor = Color(0xFF9E9E9E);  // Grey text color
  static const Color accentColor = Color(0xFF4CAF50);  // Success green
  static const Color errorColor = Color(0xFFE53935);  // Error red

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFFED1C24);
  static const Color darkSecondaryColor = Color(0xFFFF4F4F);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimaryColor = Color(0xFFFFFFFF);
  static const Color darkTextSecondaryColor = Color(0x68B0B0B0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:  backgroundColor,
      // foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // textTheme: const TextTheme(
    //   headlineLarge: TextStyle(
    //     color: textPrimaryColor,
    //     fontSize: 28,
    //     fontWeight: FontWeight.bold,
    //   ),
    //   headlineMedium: TextStyle(
    //     color: textPrimaryColor,
    //     fontSize: 24,
    //     fontWeight: FontWeight.w600,
    //   ),
    //   bodyLarge: TextStyle(
    //     color: textPrimaryColor,
    //     fontSize: 16,
    //   ),
    //   bodyMedium: TextStyle(
    //     color: textSecondaryColor,
    //     fontSize: 14,
    //   ),
    // ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey),
      // filled: true,
      // fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: textSecondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      // contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: backgroundColor,
      indicatorColor: primaryColor,
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(color: textPrimaryColor),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      error: errorColor,
      surface: darkSurfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      // foregroundColor: darkTextPrimaryColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkTextPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    // textTheme: const TextTheme(
    //   headlineLarge: TextStyle(
    //     color: darkTextPrimaryColor,
    //     fontSize: 28,
    //     fontWeight: FontWeight.bold,
    //   ),
    //   headlineMedium: TextStyle(
    //     color: darkTextPrimaryColor,
    //     fontSize: 24,
    //     fontWeight: FontWeight.w600,
    //   ),
    //   bodyLarge: TextStyle(
    //     color: darkTextPrimaryColor,
    //     fontSize: 16,
    //   ),
    //   bodyMedium: TextStyle(
    //     color: darkTextSecondaryColor,
    //     fontSize: 14,
    //   ),
    // ),
    inputDecorationTheme: InputDecorationTheme(
      // filled: true,
      // fillColor: darkSurfaceColor,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.redAccent)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkTextSecondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      // contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkBackgroundColor,
      indicatorColor: darkPrimaryColor,
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(color: darkTextPrimaryColor),
      ),
    ),
  );
}
