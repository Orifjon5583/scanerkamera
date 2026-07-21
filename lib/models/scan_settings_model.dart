/// Represents user-configurable scan settings.
class ScanSettingsModel {
  final ImageQuality imageQuality;
  final PdfQuality pdfQuality;
  final OcrLanguage ocrLanguage;
  final bool autoCapture;
  final bool showGrid;
  final bool flashEnabled;

  const ScanSettingsModel({
    this.imageQuality = ImageQuality.high,
    this.pdfQuality = PdfQuality.high,
    this.ocrLanguage = OcrLanguage.english,
    this.autoCapture = true,
    this.showGrid = false,
    this.flashEnabled = false,
  });

  ScanSettingsModel copyWith({
    ImageQuality? imageQuality,
    PdfQuality? pdfQuality,
    OcrLanguage? ocrLanguage,
    bool? autoCapture,
    bool? showGrid,
    bool? flashEnabled,
  }) {
    return ScanSettingsModel(
      imageQuality: imageQuality ?? this.imageQuality,
      pdfQuality: pdfQuality ?? this.pdfQuality,
      ocrLanguage: ocrLanguage ?? this.ocrLanguage,
      autoCapture: autoCapture ?? this.autoCapture,
      showGrid: showGrid ?? this.showGrid,
      flashEnabled: flashEnabled ?? this.flashEnabled,
    );
  }
}

/// Image quality presets.
enum ImageQuality {
  low(60, 'Low'),
  medium(75, 'Medium'),
  high(85, 'High'),
  maximum(95, 'Maximum');

  final int value;
  final String label;

  const ImageQuality(this.value, this.label);
}

/// PDF quality presets.
enum PdfQuality {
  low(0.5, 'Low (smaller file)'),
  medium(0.7, 'Medium'),
  high(0.85, 'High'),
  maximum(1.0, 'Maximum (larger file)');

  final double value;
  final String label;

  const PdfQuality(this.value, this.label);
}

/// Supported OCR languages.
enum OcrLanguage {
  english('en', 'English'),
  spanish('es', 'Spanish'),
  french('fr', 'French'),
  german('de', 'German'),
  italian('it', 'Italian'),
  portuguese('pt', 'Portuguese'),
  russian('ru', 'Russian'),
  chinese('zh', 'Chinese'),
  japanese('ja', 'Japanese'),
  korean('ko', 'Korean');

  final String code;
  final String label;

  const OcrLanguage(this.code, this.label);
}
