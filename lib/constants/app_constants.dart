import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color errorColor = Colors.red;

  // Fonts
  static const double fontSizeLarge = 24.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeSmall = 14.0;

  // Sizes
  static const double buttonHeight = 50.0;
  static const double paddingLarge = 20.0;
  static const double paddingMedium = 10.0;

  // Styles - THESE ARE USED IN YOUR SCREENS
  static TextStyle titleStyle = const TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle buttonStyle = const TextStyle(
    fontSize: fontSizeMedium,
    color: Colors.white,
  );

  static TextStyle labelStyle = const TextStyle(
    fontSize: fontSizeSmall,
    color: textColor,
  );
}