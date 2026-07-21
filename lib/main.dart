import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/app.dart';
import 'package:smartscan_ai/core/services/database_service.dart';

/// Application entry point.
/// Initializes core services and launches the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for scanning consistency
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize database
  await DatabaseService.instance.initialize();

  runApp(
    const ProviderScope(
      child: SmartScanApp(),
    ),
  );
}
