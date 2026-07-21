import 'package:flutter/material.dart';

/// Widget providing brightness and contrast adjustment sliders.
class AdjustmentSlider extends StatefulWidget {
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onContrastChanged;

  const AdjustmentSlider({
    super.key,
    required this.onBrightnessChanged,
    required this.onContrastChanged,
  });

  @override
  State<AdjustmentSlider> createState() => _AdjustmentSliderState();
}

class _AdjustmentSliderState extends State<AdjustmentSlider> {
  double _brightness = 0;
  double _contrast = 0;
  _AdjustmentType _activeType = _AdjustmentType.brightness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TypeChip(
                label: 'Brightness',
                icon: Icons.brightness_6_rounded,
                isSelected: _activeType == _AdjustmentType.brightness,
                onTap: () {
                  setState(() {
                    _activeType = _AdjustmentType.brightness;
                  });
                },
              ),
              const SizedBox(width: 12),
              _TypeChip(
                label: 'Contrast',
                icon: Icons.contrast_rounded,
                isSelected: _activeType == _AdjustmentType.contrast,
                onTap: () {
                  setState(() {
                    _activeType = _AdjustmentType.contrast;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          Row(
            children: [
              Text(
                _activeType == _AdjustmentType.brightness
                    ? '${_brightness.toInt()}'
                    : '${_contrast.toInt()}',
                style: theme.textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: _activeType == _AdjustmentType.brightness
                      ? _brightness
                      : _contrast,
                  min: -100,
                  max: 100,
                  divisions: 200,
                  label: _activeType == _AdjustmentType.brightness
                      ? '${_brightness.toInt()}'
                      : '${_contrast.toInt()}',
                  onChanged: (value) {
                    setState(() {
                      if (_activeType == _AdjustmentType.brightness) {
                        _brightness = value;
                      } else {
                        _contrast = value;
                      }
                    });
                  },
                  onChangeEnd: (value) {
                    if (_activeType == _AdjustmentType.brightness) {
                      widget.onBrightnessChanged(value);
                    } else {
                      widget.onContrastChanged(value);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded, size: 20),
                onPressed: () {
                  setState(() {
                    if (_activeType == _AdjustmentType.brightness) {
                      _brightness = 0;
                      widget.onBrightnessChanged(0);
                    } else {
                      _contrast = 0;
                      widget.onContrastChanged(0);
                    }
                  });
                },
                tooltip: 'Reset',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _AdjustmentType { brightness, contrast }

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
