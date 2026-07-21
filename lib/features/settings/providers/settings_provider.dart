import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/models/scan_settings_model.dart';
import 'package:smartscan_ai/repositories/settings_repository.dart';

/// Provider for the settings repository.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Provider for the application settings.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

/// Application settings model.
class AppSettings {
  final ThemeMode themeMode;
  final String language;
  final ImageQuality imageQuality;
  final PdfQuality pdfQuality;
  final OcrLanguage ocrLanguage;
  final bool autoCapture;
  final bool showGrid;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.imageQuality = ImageQuality.high,
    this.pdfQuality = PdfQuality.high,
    this.ocrLanguage = OcrLanguage.english,
    this.autoCapture = true,
    this.showGrid = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? language,
    ImageQuality? imageQuality,
    PdfQuality? pdfQuality,
    OcrLanguage? ocrLanguage,
    bool? autoCapture,
    bool? showGrid,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      imageQuality: imageQuality ?? this.imageQuality,
      pdfQuality: pdfQuality ?? this.pdfQuality,
      ocrLanguage: ocrLanguage ?? this.ocrLanguage,
      autoCapture: autoCapture ?? this.autoCapture,
      showGrid: showGrid ?? this.showGrid,
    );
  }
}

/// Settings state notifier that persists changes.
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AppSettings()) {
    _loadSettings();
  }

  /// Loads persisted settings from the database.
  Future<void> _loadSettings() async {
    final themeStr = await _repository.getSetting('theme_mode');
    final language = await _repository.getSetting('language');
    final imageQualityStr = await _repository.getSetting('image_quality');
    final pdfQualityStr = await _repository.getSetting('pdf_quality');
    final ocrLanguageStr = await _repository.getSetting('ocr_language');
    final autoCaptureStr = await _repository.getSetting('auto_capture');
    final showGridStr = await _repository.getSetting('show_grid');

    state = AppSettings(
      themeMode: _parseThemeMode(themeStr),
      language: language ?? 'en',
      imageQuality: _parseImageQuality(imageQualityStr),
      pdfQuality: _parsePdfQuality(pdfQualityStr),
      ocrLanguage: _parseOcrLanguage(ocrLanguageStr),
      autoCapture: autoCaptureStr != 'false',
      showGrid: showGridStr == 'true',
    );
  }

  /// Updates the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repository.setSetting('theme_mode', mode.name);
  }

  /// Updates the language.
  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _repository.setSetting('language', language);
  }

  /// Updates image quality.
  Future<void> setImageQuality(ImageQuality quality) async {
    state = state.copyWith(imageQuality: quality);
    await _repository.setSetting('image_quality', quality.name);
  }

  /// Updates PDF quality.
  Future<void> setPdfQuality(PdfQuality quality) async {
    state = state.copyWith(pdfQuality: quality);
    await _repository.setSetting('pdf_quality', quality.name);
  }

  /// Updates OCR language.
  Future<void> setOcrLanguage(OcrLanguage language) async {
    state = state.copyWith(ocrLanguage: language);
    await _repository.setSetting('ocr_language', language.name);
  }

  /// Updates auto-capture setting.
  Future<void> setAutoCapture(bool value) async {
    state = state.copyWith(autoCapture: value);
    await _repository.setSetting('auto_capture', value.toString());
  }

  /// Updates grid display setting.
  Future<void> setShowGrid(bool value) async {
    state = state.copyWith(showGrid: value);
    await _repository.setSetting('show_grid', value.toString());
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ImageQuality _parseImageQuality(String? value) {
    return ImageQuality.values.firstWhere(
      (q) => q.name == value,
      orElse: () => ImageQuality.high,
    );
  }

  PdfQuality _parsePdfQuality(String? value) {
    return PdfQuality.values.firstWhere(
      (q) => q.name == value,
      orElse: () => PdfQuality.high,
    );
  }

  OcrLanguage _parseOcrLanguage(String? value) {
    return OcrLanguage.values.firstWhere(
      (l) => l.name == value,
      orElse: () => OcrLanguage.english,
    );
  }
}
