import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_ai/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

/// Utility class for image processing operations.
/// Handles cropping, rotation, filters, and enhancement.
class ImageUtils {
  ImageUtils._();

  static const _uuid = Uuid();

  /// Generates a unique file name for scanned images.
  static String generateImageFileName() {
    return 'scan_${_uuid.v4()}${AppConstants.jpgExtension}';
  }

  /// Gets the application's scans directory path.
  static Future<String> getScansDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final scansDir = Directory('${appDir.path}/${AppConstants.scansDirectory}');
    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }
    return scansDir.path;
  }

  /// Gets the thumbnails directory path.
  static Future<String> getThumbnailsDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbDir =
        Directory('${appDir.path}/${AppConstants.thumbnailsDirectory}');
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    return thumbDir.path;
  }

  /// Gets the exports directory path.
  static Future<String> getExportsDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final exportDir =
        Directory('${appDir.path}/${AppConstants.exportsDirectory}');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  /// Rotates an image by the specified degrees (90, 180, 270).
  static Future<File> rotateImage(String imagePath, int degrees) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    img.Image rotated;
    switch (degrees % 360) {
      case 90:
        rotated = img.copyRotate(image, angle: 90);
        break;
      case 180:
        rotated = img.copyRotate(image, angle: 180);
        break;
      case 270:
        rotated = img.copyRotate(image, angle: 270);
        break;
      default:
        rotated = image;
    }

    final outputBytes = img.encodeJpg(rotated, quality: AppConstants.defaultImageQuality);
    await file.writeAsBytes(outputBytes);
    return file;
  }

  /// Adjusts brightness of an image. Value range: -100 to 100.
  static Future<File> adjustBrightness(String imagePath, int value) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    final adjusted = img.adjustColor(image, brightness: value / 100.0);
    final outputBytes = img.encodeJpg(adjusted, quality: AppConstants.defaultImageQuality);
    await file.writeAsBytes(outputBytes);
    return file;
  }

  /// Adjusts contrast of an image. Value range: -100 to 100.
  static Future<File> adjustContrast(String imagePath, double value) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    final adjusted = img.adjustColor(image, contrast: value / 100.0);
    final outputBytes = img.encodeJpg(adjusted, quality: AppConstants.defaultImageQuality);
    await file.writeAsBytes(outputBytes);
    return file;
  }

  /// Applies grayscale filter to an image.
  static Future<File> applyGrayscale(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    final grayscale = img.grayscale(image);
    final outputBytes = img.encodeJpg(grayscale, quality: AppConstants.defaultImageQuality);
    await file.writeAsBytes(outputBytes);
    return file;
  }

  /// Applies black and white (threshold) filter to an image.
  static Future<File> applyBlackAndWhite(
    String imagePath, {
    int threshold = 128,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    final grayscale = img.grayscale(image);
    // Apply threshold to make black and white
    for (int y = 0; y < grayscale.height; y++) {
      for (int x = 0; x < grayscale.width; x++) {
        final pixel = grayscale.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        if (luminance > threshold) {
          grayscale.setPixelRgb(x, y, 255, 255, 255);
        } else {
          grayscale.setPixelRgb(x, y, 0, 0, 0);
        }
      }
    }

    final outputBytes = img.encodeJpg(grayscale, quality: AppConstants.defaultImageQuality);
    await file.writeAsBytes(outputBytes);
    return file;
  }

  /// Applies magic color enhancement filter.
  /// Increases saturation and sharpness for document readability.
  static Future<File> applyMagicColor(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    // Enhance saturation and contrast for document readability
    var enhanced = img.adjustColor(
      image,
      contrast: 0.3,
      saturation: 1.2,
      brightness: 0.05,
    );

    // Apply light sharpen for text clarity
    enhanced = img.convolution(enhanced, filter: [
      0, -1, 0,
      -1, 5, -1,
      0, -1, 0,
    ], div: 1);

    final outputBytes = img.encodeJpg(enhanced, quality: AppConstants.defaultImageQuality);
    await file.writeAsBytes(outputBytes);
    return file;
  }

  /// Generates a thumbnail from an image file.
  static Future<File> generateThumbnail(
    String imagePath, {
    int width = 200,
    int height = 280,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    final thumbnail = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );

    final thumbDir = await getThumbnailsDirectoryPath();
    final thumbPath = '$thumbDir/thumb_${_uuid.v4()}${AppConstants.jpgExtension}';
    final thumbFile = File(thumbPath);
    await thumbFile.writeAsBytes(
      img.encodeJpg(thumbnail, quality: 70),
    );

    return thumbFile;
  }

  /// Crops an image to the specified rectangle.
  static Future<File> cropImage(
    String imagePath, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    final cropped = img.copyCrop(
      image,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    final outputBytes = img.encodeJpg(cropped, quality: AppConstants.defaultImageQuality);
    await file.writeAsBytes(outputBytes);
    return file;
  }

  /// Applies sharpening to an image.
  static Future<File> sharpenImage(String imagePath, {double amount = 1.0}) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    // Unsharp mask approach
    final sharpened = img.convolution(image, filter: [
      0, -1 * amount, 0,
      -1 * amount, 1 + 4 * amount, -1 * amount,
      0, -1 * amount, 0,
    ], div: 1);

    final outputBytes = img.encodeJpg(sharpened, quality: AppConstants.defaultImageQuality);
    await file.writeAsBytes(outputBytes);
    return file;
  }

  /// Copies an image file to a new path.
  static Future<File> copyImage(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    return sourceFile.copy(destinationPath);
  }

  /// Deletes an image file safely.
  static Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Gets image dimensions without loading full image.
  static Future<({int width, int height})?> getImageDimensions(
    String imagePath,
  ) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return null;
    return (width: image.width, height: image.height);
  }
}
