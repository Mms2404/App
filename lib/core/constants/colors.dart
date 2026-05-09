import 'package:flutter/material.dart';

class AppColors {
  // Core surfaces — layered dark
  static const Color bgBase = Color(0xFF0E0E0E);      // deepest background
  static const Color bgSurface = Color(0xFF1A1A1A);   // cards, elevated surfaces
  static const Color bgElevated = Color(0xFF242424);  // modals, overlays

  // Text — opacity-driven hierarchy on dark
  static const Color textPrimary = Color(0xFFF2F2F2);     // 95% white
  static const Color textSecondary = Color(0x99FFFFFF);   // 60% white
  static const Color textTertiary = Color(0x66FFFFFF);    // 40% white
  static const Color textDisabled = Color(0x33FFFFFF);    // 20% white

  // Single accent — cool aqua, ties to orb
  static const Color accent = Color(0xFF5DE6C8);          // primary CTA, focus rings
  static const Color accentSoft = Color(0xFF5DE6C8);      // use with opacity for fills
  static const Color accentDeep = Color(0xFF1FA088);      // pressed state

  // Borders — barely there
  static const Color border = Color(0x14FFFFFF);          // 8% white, default
  static const Color borderStrong = Color(0x29FFFFFF);    // 16% white, hover/focus

  // Semantic
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFACC15);
  static const Color danger = Color(0xFFEB8B6E);          // kept your soft coral — works in dark
  static const Color info = Color(0xFF60A5FA);

  // Legacy aliases — keep if your existing code references them.
  // Delete after you migrate.
  static const Color black = bgBase;
  static const Color white = textPrimary;
  static const Color grey = textSecondary;
  static const Color palegreen = accent;
}

class AppGradient {
  /// Subtle dark gradient for screens that don't use OrbBackground.
  /// Use sparingly — most screens should be flat AppColors.bgBase.
  static const LinearGradient ambientDark = LinearGradient(
    colors: [
      Color(0xFF0E0E0E),
      Color(0xFF141A1F),
      Color(0xFF0E0E0E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  /// Accent gradient for occasional emphasis — featured cards,
  /// premium badges, hero stats. Don't use as a screen background.
  static const LinearGradient accentSheen = LinearGradient(
    colors: [
      Color(0xFF5DE6C8),
      Color(0xFF3CB8E6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass overlay — apply over a blurred surface for iOS-style
  /// floating nav bars or modal headers.
  static const LinearGradient glassSurface = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0AFFFFFF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );


}