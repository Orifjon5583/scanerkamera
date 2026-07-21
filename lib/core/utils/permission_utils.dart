import 'package:permission_handler/permission_handler.dart';

/// Utility class for handling runtime permissions.
class PermissionUtils {
  PermissionUtils._();

  /// Requests camera permission.
  /// Returns true if granted.
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Requests storage permission.
  /// Returns true if granted.
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Checks if camera permission is granted.
  static Future<bool> hasCameraPermission() async {
    return Permission.camera.isGranted;
  }

  /// Checks if storage permission is granted.
  static Future<bool> hasStoragePermission() async {
    return Permission.storage.isGranted;
  }

  /// Requests all required permissions for the app.
  /// Returns true if all are granted.
  static Future<bool> requestAllPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  /// Opens app settings for the user to manually grant permissions.
  static Future<bool> openSettings() async {
    return openAppSettings();
  }
}
