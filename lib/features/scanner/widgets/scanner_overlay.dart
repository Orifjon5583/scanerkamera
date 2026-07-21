import 'package:flutter/material.dart';
import 'package:smartscan_ai/core/theme/app_colors.dart';

/// Overlay widget showing the document detection boundary.
/// Displays corner markers and edge guides.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.scannerBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cornerPaint = Paint()
      ..color = AppColors.scannerCorner
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Document area (centered with margin)
    final margin = size.width * 0.08;
    final rect = Rect.fromLTWH(
      margin,
      size.height * 0.15,
      size.width - margin * 2,
      size.height * 0.65,
    );

    // Draw semi-transparent overlay outside the document area
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Top region
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, rect.top),
      overlayPaint,
    );
    // Bottom region
    canvas.drawRect(
      Rect.fromLTWH(0, rect.bottom, size.width, size.height - rect.bottom),
      overlayPaint,
    );
    // Left region
    canvas.drawRect(
      Rect.fromLTWH(0, rect.top, rect.left, rect.height),
      overlayPaint,
    );
    // Right region
    canvas.drawRect(
      Rect.fromLTWH(rect.right, rect.top, size.width - rect.right, rect.height),
      overlayPaint,
    );

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      borderPaint,
    );

    // Draw corner markers
    const cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
