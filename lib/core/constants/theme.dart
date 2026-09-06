import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData themeData = ThemeData(
    fontFamily: "Manrope",
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}