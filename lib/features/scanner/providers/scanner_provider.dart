import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartscan_ai/services/scanner_service.dart';

/// Provider for the scanner state notifier.
final scannerNotifierProvider =
    StateNotifierProvider.autoDispose<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier();
});

/// State for the scanner screen.
class ScannerState {
  final bool isInitialized;
  final bool isCapturing;
  final CameraController? controller;
  final FlashMode flashMode;
  final bool showGrid;
  final List<String> capturedPages;
  final String? error;

  const ScannerState({
    this.isInitialized = false,
    this.isCapturing = false,
    this.controller,
    this.flashMode = FlashMode.off,
    this.showGrid = false,
    this.capturedPages = const [],
    this.error,
  });

  ScannerState copyWith({
    bool? isInitialized,
    bool? isCapturing,
    CameraController? controller,
    FlashMode? flashMode,
    bool? showGrid,
    List<String>? capturedPages,
    String? error,
  }) {
    return ScannerState(
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      controller: controller ?? this.controller,
      flashMode: flashMode ?? this.flashMode,
      showGrid: showGrid ?? this.showGrid,
      capturedPages: capturedPages ?? this.capturedPages,
      error: error,
    );
  }
}

/// State notifier managing scanner operations.
class ScannerNotifier extends StateNotifier<ScannerState> {
  final ScannerService _scannerService = ScannerService();
  final ImagePicker _imagePicker = ImagePicker();

  ScannerNotifier() : super(const ScannerState());

  /// Initializes the camera for scanning.
  Future<void> initializeCamera() async {
    try {
      final controller = await _scannerService.initializeCamera();
      state = state.copyWith(
        isInitialized: true,
        controller: controller,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Captures an image from the camera.
  Future<String?> captureImage() async {
    if (state.isCapturing) return null;

    state = state.copyWith(isCapturing: true);

    try {
      final imagePath = await _scannerService.captureImage();
      state = state.copyWith(
        isCapturing: false,
        capturedPages: [...state.capturedPages, imagePath],
      );
      return imagePath;
    } catch (e) {
      state = state.copyWith(
        isCapturing: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Toggles the flash mode.
  Future<void> toggleFlash() async {
    try {
      final newMode = await _scannerService.toggleFlash();
      state = state.copyWith(flashMode: newMode);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggles the grid overlay.
  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  /// Picks an image from the gallery.
  Future<void> pickFromGallery() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 90,
      );

      if (pickedFiles.isNotEmpty) {
        final newPaths = pickedFiles.map((f) => f.path).toList();
        state = state.copyWith(
          capturedPages: [...state.capturedPages, ...newPaths],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Removes a captured page.
  void removePage(int index) {
    if (index >= 0 && index < state.capturedPages.length) {
      final pages = List<String>.from(state.capturedPages);
      pages.removeAt(index);
      state = state.copyWith(capturedPages: pages);
    }
  }

  /// Pauses the camera (e.g., when app goes to background).
  void pauseCamera() {
    // Camera controller handles lifecycle internally
  }

  /// Resumes the camera.
  Future<void> resumeCamera() async {
    if (!state.isInitialized) {
      await initializeCamera();
    }
  }

  /// Disposes camera resources.
  Future<void> dispose() async {
    await _scannerService.dispose();
    super.dispose();
  }
}
