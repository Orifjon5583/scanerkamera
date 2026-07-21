import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:smartscan_ai/core/utils/image_utils.dart';
import 'package:uuid/uuid.dart';

/// Service responsible for camera operations and edge detection.
/// Provides document scanning capabilities with auto-detection.
class ScannerService {
  static const _uuid = Uuid();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  /// Gets available cameras.
  Future<List<CameraDescription>> getAvailableCameras() async {
    _cameras ??= await availableCameras();
    return _cameras!;
  }

  /// Initializes the camera controller.
  Future<CameraController> initializeCamera({
    ResolutionPreset resolution = ResolutionPreset.high,
    bool enableAudio = false,
  }) async {
    final cameras = await getAvailableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    // Prefer back camera for document scanning
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      resolution,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController!.initialize();
    return _cameraController!;
  }

  /// Gets the current camera controller.
  CameraController? get controller => _cameraController;

  /// Captures a photo and returns the file path.
  Future<String> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final xFile = await _cameraController!.takePicture();
    final scansDir = await ImageUtils.getScansDirectoryPath();
    final fileName = ImageUtils.generateImageFileName();
    final newPath = '$scansDir/$fileName';

    // Move captured file to scans directory
    final capturedFile = File(xFile.path);
    await capturedFile.copy(newPath);
    await capturedFile.delete();

    return newPath;
  }

  /// Toggles flash mode.
  Future<FlashMode> toggleFlash() async {
    if (_cameraController == null) throw Exception('Camera not initialized');

    final currentMode = _cameraController!.value.flashMode;
    FlashMode newMode;

    switch (currentMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
    }

    await _cameraController!.setFlashMode(newMode);
    return newMode;
  }

  /// Sets a specific flash mode.
  Future<void> setFlashMode(FlashMode mode) async {
    if (_cameraController == null) throw Exception('Camera not initialized');
    await _cameraController!.setFlashMode(mode);
  }

  /// Detects document edges in an image.
  /// Returns corner points as a list of (x, y) offsets normalized to 0-1.
  /// Uses a simplified edge detection approach suitable for documents.
  Future<List<({double x, double y})>> detectEdges(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      // Return full image corners as fallback
      return [
        (x: 0.0, y: 0.0),
        (x: 1.0, y: 0.0),
        (x: 1.0, y: 1.0),
        (x: 0.0, y: 1.0),
      ];
    }

    // Convert to grayscale for edge processing
    final grayscale = img.grayscale(image);

    // Apply Gaussian blur to reduce noise
    final blurred = img.gaussianBlur(grayscale, radius: 3);

    // Simple edge detection using Sobel-like approach
    // Find the document boundaries by scanning from edges
    final width = blurred.width;
    final height = blurred.height;

    // Sample points to find document boundaries
    double topEdge = 0.05;
    double bottomEdge = 0.95;
    double leftEdge = 0.05;
    double rightEdge = 0.95;

    // Scan from top
    for (int y = 0; y < height ~/ 4; y++) {
      int edgeCount = 0;
      for (int x = width ~/ 4; x < 3 * width ~/ 4; x++) {
        final pixel = blurred.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        if (luminance < 200) edgeCount++;
      }
      if (edgeCount > width ~/ 4) {
        topEdge = y / height;
        break;
      }
    }

    // Scan from bottom
    for (int y = height - 1; y > 3 * height ~/ 4; y--) {
      int edgeCount = 0;
      for (int x = width ~/ 4; x < 3 * width ~/ 4; x++) {
        final pixel = blurred.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        if (luminance < 200) edgeCount++;
      }
      if (edgeCount > width ~/ 4) {
        bottomEdge = y / height;
        break;
      }
    }

    // Scan from left
    for (int x = 0; x < width ~/ 4; x++) {
      int edgeCount = 0;
      for (int y = height ~/ 4; y < 3 * height ~/ 4; y++) {
        final pixel = blurred.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        if (luminance < 200) edgeCount++;
      }
      if (edgeCount > height ~/ 4) {
        leftEdge = x / width;
        break;
      }
    }

    // Scan from right
    for (int x = width - 1; x > 3 * width ~/ 4; x--) {
      int edgeCount = 0;
      for (int y = height ~/ 4; y < 3 * height ~/ 4; y++) {
        final pixel = blurred.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        if (luminance < 200) edgeCount++;
      }
      if (edgeCount > height ~/ 4) {
        rightEdge = x / width;
        break;
      }
    }

    return [
      (x: leftEdge, y: topEdge),
      (x: rightEdge, y: topEdge),
      (x: rightEdge, y: bottomEdge),
      (x: leftEdge, y: bottomEdge),
    ];
  }

  /// Applies perspective correction to crop the document.
  Future<String> applyPerspectiveCorrection(
    String imagePath,
    List<({double x, double y})> corners,
  ) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Failed to decode image');

    final width = image.width;
    final height = image.height;

    // Convert normalized corners to pixel coordinates
    final topLeft = (x: (corners[0].x * width).round(), y: (corners[0].y * height).round());
    final topRight = (x: (corners[1].x * width).round(), y: (corners[1].y * height).round());
    final bottomRight = (x: (corners[2].x * width).round(), y: (corners[2].y * height).round());
    final bottomLeft = (x: (corners[3].x * width).round(), y: (corners[3].y * height).round());

    // Calculate output dimensions
    final outputWidth = math.max(
      _distance(topLeft.x, topLeft.y, topRight.x, topRight.y),
      _distance(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y),
    ).round();

    final outputHeight = math.max(
      _distance(topLeft.x, topLeft.y, bottomLeft.x, bottomLeft.y),
      _distance(topRight.x, topRight.y, bottomRight.x, bottomRight.y),
    ).round();

    // Simple crop approach as perspective transform approximation
    final cropX = topLeft.x.clamp(0, width - 1);
    final cropY = topLeft.y.clamp(0, height - 1);
    final cropW = (outputWidth).clamp(1, width - cropX);
    final cropH = (outputHeight).clamp(1, height - cropY);

    final cropped = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    final scansDir = await ImageUtils.getScansDirectoryPath();
    final fileName = 'corrected_${_uuid.v4()}.jpg';
    final outputPath = '$scansDir/$fileName';

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(img.encodeJpg(cropped, quality: 90));

    return outputPath;
  }

  /// Calculates distance between two points.
  double _distance(int x1, int y1, int x2, int y2) {
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }

  /// Disposes the camera controller.
  Future<void> dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}
