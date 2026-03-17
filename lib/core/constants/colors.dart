import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Color(0xFF313131);
  static const Color grey = Colors.grey;
  static const Color white = Color(0xFFFFFFFF);
  static const Color palegreen = Color(0xFFcde7aa);
  

}


class AppGradient{
  static LinearGradient softBackgroundGradient =LinearGradient(
    colors: [
      Color(0xFFcde7aa), // palegreen
      Color(0xFFebb76e), // softOrange
      Color(0xFFcd755b), // warmRed softened with 50% opacity
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.15, 0.85, 1.0], // smoother transitions spaced evenly
    tileMode: TileMode.clamp,
  );
}

