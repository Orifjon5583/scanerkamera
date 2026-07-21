import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/theme/app_theme.dart';
import 'package:smartscan_ai/core/router/app_router.dart';
import 'package:smartscan_ai/features/settings/providers/settings_provider.dart';

/// Root application widget.
/// Configures theme, routing, and global providers.
class SmartScanApp extends ConsumerWidget {
  const SmartScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = settings.themeMode;

    return MaterialApp(
      title: 'SmartScan AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
