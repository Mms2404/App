import 'package:logger/logger.dart';

/// Global logger. Silenced in release builds via the level set in main().
final log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,         // hide stack trace for normal logs
    // errorMethodCount: 5,    // show 5 lines for errors ; by Default 8
    lineLength: 80,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);



// Logger usage : 
// log.t('Entering _handleSubmit()');                          // trace — verbose flow tracking
// log.d('Email field value: ${_emailCtrl.text}');             // debug — values you're inspecting
// log.i('User logged in: ${user.email}');                     // info — meaningful events
// log.w('Token expires in 30s, refreshing');                  // warning — odd but handled
// log.e('Login failed', error: e, stackTrace: st);            // error — something broke
// log.f('Database unreachable, app cannot continue');         // fatal — app-breaking