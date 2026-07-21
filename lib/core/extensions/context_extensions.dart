import 'package:flutter/material.dart';

/// Extension methods on BuildContext for convenient access to common properties.
extension ContextExtensions on BuildContext {
  /// Gets the current theme data.
  ThemeData get theme => Theme.of(this);

  /// Gets the current color scheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Gets the current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Gets the screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Gets the screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Gets the screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Gets the device padding (safe area).
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// Checks if the device is in dark mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Shows a snackbar with a message.
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Shows an error snackbar.
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
      ),
    );
  }
}
