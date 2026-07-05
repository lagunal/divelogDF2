import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:divedatapro/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:divedatapro/services/subscription_service.dart';
import 'package:divedatapro/screens/auth_wrapper.dart';
import 'package:divedatapro/theme.dart';
import 'package:divedatapro/providers/dive_provider.dart';
import 'package:logging/logging.dart';
import 'package:divedatapro/widgets/error_boundary.dart';
import 'dart:developer' as developer;

void main() async {
  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    developer.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });

  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Capture all Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Logger('Flutter').severe('FlutterError', details.exception, details.stack);
  };

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize RevenueCat
  await SubscriptionService().initialize();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiveProvider(),
      child: ErrorBoundary(
        child: MaterialApp(
          title: 'DiveDataPro',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
