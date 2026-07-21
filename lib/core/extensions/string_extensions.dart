/// Extension methods on String for common operations.
extension StringExtensions on String {
  /// Capitalizes the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes each word.
  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncates the string to the specified length with ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Checks if the string is a valid file name.
  bool get isValidFileName {
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return isNotEmpty && !invalidChars.hasMatch(this);
  }

  /// Removes file extension from a string.
  String get withoutExtension {
    final lastDot = lastIndexOf('.');
    if (lastDot == -1) return this;
    return substring(0, lastDot);
  }

  /// Gets the file extension.
  String get fileExtension {
    final lastDot = lastIndexOf('.');
    if (lastDot == -1) return '';
    return substring(lastDot);
  }
}
