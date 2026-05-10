import 'package:app/core/constants/theme.dart';
import 'package:app/features/onboarding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void main() {
  Logger.level = kDebugMode ? Level.debug : Level.off;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home:Onboarding(),
    );
  }
}

