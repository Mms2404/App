import 'package:app/core/constants/theme.dart';
import 'package:app/features/onboarding.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://your-supabase-url.supabase.co',
    publishableKey: 'your-supabase-publishable-key'
    );
  Logger.level = kDebugMode ? Level.debug : Level.off;  // Logs only in debug mode 
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
    // ScreenUtil makes sure the app is responsive across different screen sizes. It should wrap the entire app.
    // Anything that's a dimension in pixels → ScreenUtil. Anything that's a ratio, fraction, or multiplier → raw value.
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          // debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          home: const Onboarding(),
        );
      },
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