import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/router/app_router.dart';
import 'package:smartscan_ai/core/theme/app_colors.dart';
import 'package:smartscan_ai/core/utils/permission_utils.dart';
import 'package:smartscan_ai/features/editor/views/editor_screen.dart';
import 'package:smartscan_ai/features/scanner/providers/scanner_provider.dart';
import 'package:smartscan_ai/features/scanner/widgets/scanner_overlay.dart';
import 'package:smartscan_ai/features/scanner/widgets/scanner_controls.dart';

/// Camera-based document scanner screen.
/// Provides live preview with edge detection and capture controls.
class ScannerScreen extends ConsumerStatefulWidget {
  final String? existingDocumentId;

  const ScannerScreen({super.key, this.existingDocumentId});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(scannerNotifierProvider.notifier).dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final scanner = ref.read(scannerNotifierProvider.notifier);
    if (state == AppLifecycleState.inactive) {
      scanner.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      scanner.resumeCamera();
    }
  }

  Future<void> _initCamera() async {
    final hasPermission = await PermissionUtils.requestCameraPermission();
    if (!hasPermission) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return;
    }
    await ref.read(scannerNotifierProvider.notifier).initializeCamera();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'SmartScan AI needs camera access to scan documents. Please grant permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionUtils.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (scannerState.isInitialized && scannerState.controller != null)
              Positioned.fill(
                child: CameraPreview(controller: scannerState.controller!),
              )
            else
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // Grid overlay
            if (scannerState.showGrid)
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(),
                ),
              ),

            // Scanner overlay for edge detection visualization
            if (scannerState.isInitialized)
              const Positioned.fill(
                child: ScannerOverlay(),
              ),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    // Flash toggle
                    IconButton(
                      icon: Icon(
                        _getFlashIcon(scannerState.flashMode),
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ref
                            .read(scannerNotifierProvider.notifier)
                            .toggleFlash();
                      },
                    ),
                    // Grid toggle
                    IconButton(
                      icon: Icon(
                        scannerState.showGrid
                            ? Icons.grid_on
                            : Icons.grid_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ref
                            .read(scannerNotifierProvider.notifier)
                            .toggleGrid();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ScannerControls(
                capturedCount: scannerState.capturedPages.length,
                isCapturing: scannerState.isCapturing,
                onCapture: () => _captureImage(),
                onDone: scannerState.capturedPages.isNotEmpty
                    ? () => _finishScanning()
                    : null,
                onGallery: () => _pickFromGallery(),
              ),
            ),

            // Captured pages indicator
            if (scannerState.capturedPages.isNotEmpty)
              Positioned(
                bottom: 120,
                left: 16,
                child: GestureDetector(
                  onTap: () => _finishScanning(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySeed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${scannerState.capturedPages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    final imagePath =
        await ref.read(scannerNotifierProvider.notifier).captureImage();
    if (imagePath != null && mounted) {
      // Show quick preview animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Page ${ref.read(scannerNotifierProvider).capturedPages.length} captured',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _finishScanning() async {
    final capturedPages = ref.read(scannerNotifierProvider).capturedPages;
    if (capturedPages.isEmpty) return;

    // Navigate to editor with captured images
    Navigator.pushReplacementNamed(
      context,
      AppRouter.editor,
      arguments: EditorScreenArgs(
        imagePaths: capturedPages,
        existingDocumentId: widget.existingDocumentId,
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    await ref.read(scannerNotifierProvider.notifier).pickFromGallery();
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.torch:
        return Icons.highlight_rounded;
    }
  }
}

/// Widget that displays the camera preview.
class CameraPreview extends StatelessWidget {
  final CameraController controller;

  const CameraPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 0,
            height: controller.value.previewSize?.width ?? 0,
            child: CameraPreview._buildPreview(controller),
          ),
        ),
      ),
    );
  }

  static Widget _buildPreview(CameraController controller) {
    return controller.buildPreview();
  }
}

/// Custom painter for the grid overlay.
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Vertical lines (rule of thirds)
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines (rule of thirds)
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
