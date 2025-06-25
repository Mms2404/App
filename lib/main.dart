import 'package:app/screens/authentication/presentation/screens/signUp_screen.dart';
import 'package:app/screens/home.dart';
import 'package:app/screens/onboarding.dart';
import 'package:app/screens/purchase/screens/purchase.dart';
import 'package:app/screens/search.dart';
import 'package:app/screens/user/presentation/screens/expense_edit_screen.dart';
import 'package:app/screens/user/presentation/screens/expense_list_screen.dart';
import 'package:app/screens/user/presentation/screens/expense_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
        bodyMedium: GoogleFonts.oswald(textStyle: textTheme.bodyMedium),
        ),
     ),
      home:Onboarding(),
    );
  }
}

