import 'package:app/core/constants/theme.dart';
import 'package:app/features/onboarding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

void main() {
  Logger.level = kDebugMode ? Level.debug : Level.off;
  runApp(
    const ProviderScope(
      child: MyApp()
      )
    );
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





// PROVIDERSCOPE
// -----------------------------------------------------------------------------
// Riverpod requires the entire app to be wrapped in a ProviderScope. This is
// where all provider state lives. Without it, any ref.watch/read will throw.
//
// Compare to Provider: in Provider you wrapped specific subtrees with
// ChangeNotifierProvider(). In Riverpod, ProviderScope wraps the whole app
// ONCE, and providers are accessed globally — no widget-tree positioning
// required.
//
// To generate freezeed data classes, run the following command in the terminal:
// dart run build_runner build --delete-conflicting-outputs
// -----------------------------------------------------------------------------