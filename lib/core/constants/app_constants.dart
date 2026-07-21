/// Application-wide constants.
class AppConstants {
  AppConstants._();

  /// App information
  static const String appName = 'SmartScan AI';
  static const String appVersion = '1.0.0';

  /// Database
  static const String databaseName = 'smartscan.db';
  static const int databaseVersion = 1;

  /// Image quality settings
  static const int defaultImageQuality = 85;
  static const int highImageQuality = 95;
  static const int lowImageQuality = 60;

  /// PDF settings
  static const double defaultPdfQuality = 1.0;
  static const double compressedPdfQuality = 0.6;

  /// Scanner settings
  static const double edgeDetectionThreshold = 0.1;
  static const int autoCapturedelayMs = 1500;

  /// File extensions
  static const String pdfExtension = '.pdf';
  static const String jpgExtension = '.jpg';
  static const String pngExtension = '.png';
  static const String txtExtension = '.txt';

  /// Storage directories
  static const String scansDirectory = 'scans';
  static const String thumbnailsDirectory = 'thumbnails';
  static const String exportsDirectory = 'exports';
  static const String backupDirectory = 'backup';

  /// Animation durations
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 350;
  static const int longAnimationMs = 500;

  /// Grid/List view
  static const int gridCrossAxisCount = 2;
  static const double gridAspectRatio = 0.75;
}
