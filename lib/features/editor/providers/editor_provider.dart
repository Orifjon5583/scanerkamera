import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/utils/image_utils.dart';
import 'package:smartscan_ai/services/document_service.dart';

/// Provider for the editor state notifier.
final editorNotifierProvider =
    StateNotifierProvider.autoDispose<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});

/// State for the editor screen.
class EditorState {
  final List<String> images;
  final bool isProcessing;
  final String? error;

  const EditorState({
    this.images = const [],
    this.isProcessing = false,
    this.error,
  });

  EditorState copyWith({
    List<String>? images,
    bool? isProcessing,
    String? error,
  }) {
    return EditorState(
      images: images ?? this.images,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
    );
  }
}

/// Available image filters.
enum ImageFilter {
  original,
  blackAndWhite,
  grayscale,
  magic,
  sharpen,
}

/// State notifier for image editing operations.
class EditorNotifier extends StateNotifier<EditorState> {
  final DocumentService _documentService = DocumentService();

  EditorNotifier() : super(const EditorState());

  /// Loads images for editing.
  void loadImages(List<String> paths) {
    state = state.copyWith(images: List.from(paths));
  }

  /// Applies a filter to a specific page.
  Future<void> applyFilter(int pageIndex, ImageFilter filter) async {
    if (pageIndex < 0 || pageIndex >= state.images.length) return;

    state = state.copyWith(isProcessing: true);

    try {
      final imagePath = state.images[pageIndex];

      // Create a working copy so we don't modify the original until save
      final scansDir = await ImageUtils.getScansDirectoryPath();
      final workingCopy = '$scansDir/edit_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await ImageUtils.copyImage(imagePath, workingCopy);

      switch (filter) {
        case ImageFilter.original:
          // No filter applied
          break;
        case ImageFilter.blackAndWhite:
          await ImageUtils.applyBlackAndWhite(workingCopy);
          break;
        case ImageFilter.grayscale:
          await ImageUtils.applyGrayscale(workingCopy);
          break;
        case ImageFilter.magic:
          await ImageUtils.applyMagicColor(workingCopy);
          break;
        case ImageFilter.sharpen:
          await ImageUtils.sharpenImage(workingCopy);
          break;
      }

      // Update the image list
      final updatedImages = List<String>.from(state.images);
      // Delete the old working file if it was a previous edit
      if (updatedImages[pageIndex] != imagePath) {
        await ImageUtils.deleteImage(updatedImages[pageIndex]);
      }
      updatedImages[pageIndex] = workingCopy;

      state = state.copyWith(
        images: updatedImages,
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Rotates an image by the specified degrees.
  Future<void> rotateImage(int pageIndex, int degrees) async {
    if (pageIndex < 0 || pageIndex >= state.images.length) return;

    state = state.copyWith(isProcessing: true);

    try {
      final imagePath = state.images[pageIndex];
      await ImageUtils.rotateImage(imagePath, degrees);

      // Force rebuild by creating a new list reference
      state = state.copyWith(
        images: List.from(state.images),
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Adjusts brightness of an image.
  Future<void> adjustBrightness(int pageIndex, int value) async {
    if (pageIndex < 0 || pageIndex >= state.images.length) return;

    state = state.copyWith(isProcessing: true);

    try {
      final imagePath = state.images[pageIndex];
      await ImageUtils.adjustBrightness(imagePath, value);

      state = state.copyWith(
        images: List.from(state.images),
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Adjusts contrast of an image.
  Future<void> adjustContrast(int pageIndex, double value) async {
    if (pageIndex < 0 || pageIndex >= state.images.length) return;

    state = state.copyWith(isProcessing: true);

    try {
      final imagePath = state.images[pageIndex];
      await ImageUtils.adjustContrast(imagePath, value);

      state = state.copyWith(
        images: List.from(state.images),
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Saves edited images as a new document.
  Future<void> saveAsDocument(
    String name, {
    String? existingDocumentId,
  }) async {
    state = state.copyWith(isProcessing: true);

    try {
      String documentId;

      if (existingDocumentId != null) {
        documentId = existingDocumentId;
      } else {
        final document = await _documentService.createDocument(name);
        documentId = document.id;
      }

      // Add each page to the document
      for (final imagePath in state.images) {
        await _documentService.addPage(documentId, imagePath);
      }

      state = state.copyWith(isProcessing: false);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Removes a page from the editing session.
  void removePage(int index) {
    if (index >= 0 && index < state.images.length) {
      final updated = List<String>.from(state.images);
      updated.removeAt(index);
      state = state.copyWith(images: updated);
    }
  }

  /// Reorders pages.
  void reorderPages(int oldIndex, int newIndex) {
    final updated = List<String>.from(state.images);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = state.copyWith(images: updated);
  }
}
