import 'package:flutter/material.dart';

/// Bottom control bar for the scanner screen.
/// Contains capture button, gallery picker, and done button.
class ScannerControls extends StatelessWidget {
  final int capturedCount;
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback? onDone;
  final VoidCallback onGallery;

  const ScannerControls({
    super.key,
    required this.capturedCount,
    required this.isCapturing,
    required this.onCapture,
    this.onDone,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          _ControlButton(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: onGallery,
          ),

          // Capture button
          GestureDetector(
            onTap: isCapturing ? null : onCapture,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCapturing ? Colors.grey : Colors.white,
                ),
                child: isCapturing
                    ? const Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black54,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // Done button
          _ControlButton(
            icon: Icons.check_circle_outline,
            label: capturedCount > 0 ? 'Done ($capturedCount)' : 'Done',
            onTap: onDone,
            highlighted: capturedCount > 0,
          ),
        ],
      ),
    );
  }
}

/// Individual control button in the scanner bottom bar.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlighted;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = onTap == null
        ? Colors.white38
        : highlighted
            ? Colors.greenAccent
            : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
