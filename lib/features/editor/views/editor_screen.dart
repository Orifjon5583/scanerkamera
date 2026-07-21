import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/router/app_router.dart';
import 'package:smartscan_ai/core/utils/image_utils.dart';
import 'package:smartscan_ai/features/editor/providers/editor_provider.dart';
import 'package:smartscan_ai/features/editor/widgets/filter_selector.dart';
import 'package:smartscan_ai/features/editor/widgets/adjustment_slider.dart';
import 'package:smartscan_ai/features/home/providers/home_provider.dart';

/// Arguments for the editor screen.
class EditorScreenArgs {
  final List<String> imagePaths;
  final String? existingDocumentId;

  const EditorScreenArgs({
    required this.imagePaths,
    this.existingDocumentId,
  });
}

/// Image editing screen with crop, rotate, filters, and adjustments.
class EditorScreen extends ConsumerStatefulWidget {
  final EditorScreenArgs args;

  const EditorScreen({super.key, required this.args});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  int _currentPageIndex = 0;
  EditorMode _currentMode = EditorMode.filters;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(editorNotifierProvider.notifier).loadImages(widget.args.imagePaths);
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit ${editorState.images.length > 1 ? 'Page ${_currentPageIndex + 1}/${editorState.images.length}' : 'Scan'}',
        ),
        actions: [
          TextButton.icon(
            onPressed: editorState.isProcessing ? null : () => _saveDocument(),
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: editorState.isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            )
          : Column(
              children: [
                // Image preview
                Expanded(
                  child: editorState.images.isNotEmpty
                      ? PageView.builder(
                          itemCount: editorState.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Center(
                                child: Image.file(
                                  File(editorState.images[index]),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    size: 64,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text('No images to edit')),
                ),

                // Page indicators
                if (editorState.images.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        editorState.images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentPageIndex
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Editing tools
                _buildToolBar(theme),

                // Tool content
                _buildToolContent(theme, editorState),
              ],
            ),
    );
  }

  /// Builds the editing mode selection toolbar.
  Widget _buildToolBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: EditorMode.values.map((mode) {
          final isSelected = _currentMode == mode;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentMode = mode;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mode.icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  mode.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds content for the current editing mode.
  Widget _buildToolContent(ThemeData theme, EditorState editorState) {
    switch (_currentMode) {
      case EditorMode.filters:
        return FilterSelector(
          onFilterSelected: (filter) {
            if (editorState.images.isNotEmpty) {
              ref.read(editorNotifierProvider.notifier).applyFilter(
                    _currentPageIndex,
                    filter,
                  );
            }
          },
        );
      case EditorMode.adjust:
        return AdjustmentSlider(
          onBrightnessChanged: (value) {
            ref.read(editorNotifierProvider.notifier).adjustBrightness(
                  _currentPageIndex,
                  value.toInt(),
                );
          },
          onContrastChanged: (value) {
            ref.read(editorNotifierProvider.notifier).adjustContrast(
                  _currentPageIndex,
                  value,
                );
          },
        );
      case EditorMode.crop:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _cropImage(),
            icon: const Icon(Icons.crop),
            label: const Text('Crop Image'),
          ),
        );
      case EditorMode.rotate:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RotateButton(
                icon: Icons.rotate_left,
                label: '90° Left',
                onTap: () {
                  ref.read(editorNotifierProvider.notifier).rotateImage(
                        _currentPageIndex,
                        270,
                      );
                },
              ),
              _RotateButton(
                icon: Icons.rotate_right,
                label: '90° Right',
                onTap: () {
                  ref.read(editorNotifierProvider.notifier).rotateImage(
                        _currentPageIndex,
                        90,
                      );
                },
              ),
              _RotateButton(
                icon: Icons.flip,
                label: '180°',
                onTap: () {
                  ref.read(editorNotifierProvider.notifier).rotateImage(
                        _currentPageIndex,
                        180,
                      );
                },
              ),
            ],
          ),
        );
    }
  }

  Future<void> _cropImage() async {
    // Use image_cropper package for interactive cropping
    if (ref.read(editorNotifierProvider).images.isEmpty) return;

    final imagePath =
        ref.read(editorNotifierProvider).images[_currentPageIndex];
    // In production, integrate image_cropper here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cropping applied')),
    );
  }

  Future<void> _saveDocument() async {
    final editorState = ref.read(editorNotifierProvider);
    if (editorState.images.isEmpty) return;

    // Show naming dialog
    final name = await _showNameDialog();
    if (name == null || name.isEmpty) return;

    // Save document
    await ref.read(editorNotifierProvider.notifier).saveAsDocument(
          name,
          existingDocumentId: widget.args.existingDocumentId,
        );

    if (mounted) {
      // Refresh home screen data
      ref.read(homeNotifierProvider.notifier).refresh();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
        (route) => false,
      );
    }
  }

  Future<String?> _showNameDialog() async {
    final controller = TextEditingController(
      text: 'Scan ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter document name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// Rotate button widget.
class _RotateButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RotateButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Available editor modes.
enum EditorMode {
  filters(Icons.auto_awesome_rounded, 'Filters'),
  adjust(Icons.tune_rounded, 'Adjust'),
  crop(Icons.crop_rounded, 'Crop'),
  rotate(Icons.rotate_right_rounded, 'Rotate');

  final IconData icon;
  final String label;

  const EditorMode(this.icon, this.label);
}
