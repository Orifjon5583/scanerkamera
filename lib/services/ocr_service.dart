import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Service for Optical Character Recognition using Google ML Kit.
/// Extracts text from scanned document images.
class OcrService {
  TextRecognizer? _textRecognizer;

  /// Gets or creates the text recognizer instance.
  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Performs OCR on an image file and returns the extracted text.
  Future<OcrResult> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _recognizer.processImage(inputImage);

    final blocks = <OcrBlock>[];
    for (final block in recognizedText.blocks) {
      final lines = <OcrLine>[];
      for (final line in block.lines) {
        lines.add(OcrLine(
          text: line.text,
          boundingBox: line.boundingBox,
          confidence: line.confidence ?? 0.0,
        ));
      }
      blocks.add(OcrBlock(
        text: block.text,
        lines: lines,
        boundingBox: block.boundingBox,
        language: block.recognizedLanguages.isNotEmpty
            ? block.recognizedLanguages.first
            : 'unknown',
      ));
    }

    return OcrResult(
      fullText: recognizedText.text,
      blocks: blocks,
      imageWidth: 0,
      imageHeight: 0,
    );
  }

  /// Performs OCR with a specific script/language.
  Future<OcrResult> recognizeTextWithScript(
    String imagePath,
    TextRecognitionScript script,
  ) async {
    final recognizer = TextRecognizer(script: script);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await recognizer.processImage(inputImage);

      final blocks = <OcrBlock>[];
      for (final block in recognizedText.blocks) {
        final lines = <OcrLine>[];
        for (final line in block.lines) {
          lines.add(OcrLine(
            text: line.text,
            boundingBox: line.boundingBox,
            confidence: line.confidence ?? 0.0,
          ));
        }
        blocks.add(OcrBlock(
          text: block.text,
          lines: lines,
          boundingBox: block.boundingBox,
          language: block.recognizedLanguages.isNotEmpty
              ? block.recognizedLanguages.first
              : 'unknown',
        ));
      }

      return OcrResult(
        fullText: recognizedText.text,
        blocks: blocks,
        imageWidth: 0,
        imageHeight: 0,
      );
    } finally {
      await recognizer.close();
    }
  }

  /// Disposes the recognizer.
  Future<void> dispose() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
}

/// Represents the result of OCR processing.
class OcrResult {
  final String fullText;
  final List<OcrBlock> blocks;
  final int imageWidth;
  final int imageHeight;

  const OcrResult({
    required this.fullText,
    required this.blocks,
    required this.imageWidth,
    required this.imageHeight,
  });

  /// Whether any text was detected.
  bool get hasText => fullText.isNotEmpty;

  /// Gets the number of detected text blocks.
  int get blockCount => blocks.length;
}

/// Represents a block of detected text.
class OcrBlock {
  final String text;
  final List<OcrLine> lines;
  final Rect? boundingBox;
  final String language;

  const OcrBlock({
    required this.text,
    required this.lines,
    this.boundingBox,
    required this.language,
  });
}

/// Represents a single line of detected text.
class OcrLine {
  final String text;
  final Rect? boundingBox;
  final double confidence;

  const OcrLine({
    required this.text,
    this.boundingBox,
    required this.confidence,
  });
}
