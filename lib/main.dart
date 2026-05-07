import 'package:app/core/constants/theme.dart';
import 'package:app/features/onboarding.dart';
import 'package:flutter/material.dart';

void main() {
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

