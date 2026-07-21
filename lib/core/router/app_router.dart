import 'package:flutter/material.dart';
import 'package:smartscan_ai/features/home/views/home_screen.dart';
import 'package:smartscan_ai/features/scanner/views/scanner_screen.dart';
import 'package:smartscan_ai/features/editor/views/editor_screen.dart';
import 'package:smartscan_ai/features/ocr/views/ocr_screen.dart';
import 'package:smartscan_ai/features/pdf/views/pdf_preview_screen.dart';
import 'package:smartscan_ai/features/settings/views/settings_screen.dart';
import 'package:smartscan_ai/features/documents/views/document_detail_screen.dart';
import 'package:smartscan_ai/features/documents/views/folder_screen.dart';
import 'package:smartscan_ai/models/document_model.dart';

/// Centralized routing configuration.
/// Handles all navigation and route generation.
class AppRouter {
  AppRouter._();

  // Route names
  static const String home = '/';
  static const String scanner = '/scanner';
  static const String editor = '/editor';
  static const String ocr = '/ocr';
  static const String pdfPreview = '/pdf-preview';
  static const String settings = '/settings';
  static const String documentDetail = '/document-detail';
  static const String folder = '/folder';

  /// Generates routes based on route settings.
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return _buildRoute(const HomeScreen(), routeSettings);

      case scanner:
        final documentId = routeSettings.arguments as String?;
        return _buildRoute(
          ScannerScreen(existingDocumentId: documentId),
          routeSettings,
        );

      case editor:
        final args = routeSettings.arguments as EditorScreenArgs;
        return _buildRoute(
          EditorScreen(args: args),
          routeSettings,
        );

      case ocr:
        final imagePath = routeSettings.arguments as String;
        return _buildRoute(
          OcrScreen(imagePath: imagePath),
          routeSettings,
        );

      case pdfPreview:
        final document = routeSettings.arguments as DocumentModel;
        return _buildRoute(
          PdfPreviewScreen(document: document),
          routeSettings,
        );

      case settings:
        return _buildRoute(const SettingsScreen(), routeSettings);

      case documentDetail:
        final document = routeSettings.arguments as DocumentModel;
        return _buildRoute(
          DocumentDetailScreen(document: document),
          routeSettings,
        );

      case folder:
        final folderName = routeSettings.arguments as String;
        return _buildRoute(
          FolderScreen(folderName: folderName),
          routeSettings,
        );

      default:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
          routeSettings,
        );
    }
  }

  /// Creates a MaterialPageRoute with slide transition.
  static Route<dynamic> _buildRoute(
    Widget page,
    RouteSettings routeSettings,
  ) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
