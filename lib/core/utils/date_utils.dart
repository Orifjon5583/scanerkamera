import 'package:intl/intl.dart';

/// Utility class for date formatting operations.
class AppDateUtils {
  AppDateUtils._();

  /// Formats a DateTime to a readable date string.
  /// Example: "Jan 15, 2024"
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Formats a DateTime to a readable date and time string.
  /// Example: "Jan 15, 2024 at 2:30 PM"
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }

  /// Formats a DateTime to a short time string.
  /// Example: "2:30 PM"
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Returns a relative time string.
  /// Example: "2 hours ago", "Yesterday", "3 days ago"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return formatDate(date);
    }
  }

  /// Returns a string suitable for file naming.
  /// Example: "20240115_143025"
  static String formatForFileName(DateTime date) {
    return DateFormat('yyyyMMdd_HHmmss').format(date);
  }
}
