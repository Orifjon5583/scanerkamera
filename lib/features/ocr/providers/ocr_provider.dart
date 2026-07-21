import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/constants/app_constants.dart';
import 'package:smartscan_ai/core/utils/image_utils.dart';
import 'package:smartscan_ai/services/ocr_service.dart';

/// Provider for the OCR state notifier.
final ocrNotifierProvider =
    StateNotifierProvider.autoDispose<OcrNotifier, OcrState>((ref) {
  return OcrNotifier();
});

/// State for the OCR screen.
class OcrState {
  final String extractedText;
  final String highlightedText;
  final bool isProcessing;
  final String? error;
  final int blockCount;

  const OcrState({
    this.extractedText = '',
    this.highlightedText = '',
    this.isProcessing = false,
    this.error,
    this.blockCount = 0,
  });

  OcrState copyWith({
    String? extractedText,
    String? highlightedText,
    bool? isProcessing,
    String? error,
    int? blockCount,
  }) {
    return OcrState(
      extractedText: extractedText ?? this.extractedText,
      highlightedText: highlightedText ?? this.highlightedText,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      blockCount: blockCount ?? this.blockCount,
    );
  }
}

/// State notifier for OCR operations.
class OcrNotifier extends StateNotifier<OcrState> {
  final OcrService _ocrService = OcrService();

  OcrNotifier() : super(const OcrState());

  /// Processes an image for text recognition.
  Future<void> processImage(String imagePath) async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final result = await _ocrService.recognizeText(imagePath);

      state = state.copyWith(
        extractedText: result.fullText,
        isProcessing: false,
        blockCount: result.blockCount,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Failed to extract text: ${e.toString()}',
      );
    }
  }

  /// Searches within the extracted text and highlights matches.
  void searchInText(String query) {
    if (query.isEmpty) {
      state = state.copyWith(highlightedText: '');
      return;
    }

    // Simple text search - in production you could highlight the matching portions
    state = state.copyWith(highlightedText: state.extractedText);
  }

  /// Exports extracted text as a .txt file.
  Future<String> exportAsText(String text) async {
    final exportsDir = await ImageUtils.getExportsDirectoryPath();
    final fileName =
        'ocr_export_${DateTime.now().millisecondsSinceEpoch}${AppConstants.txtExtension}';
    final filePath = '$exportsDir/$fileName';

    final file = File(filePath);
    await file.writeAsString(text);
    return filePath;
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
