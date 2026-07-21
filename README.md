# SmartScan AI

A production-ready document scanner application built with Flutter, featuring OCR text recognition, intelligent edge detection, PDF generation, and comprehensive document management.

## Features

- **Smart Scanning**: Camera-based document scanning with auto edge detection
- **OCR**: Extract text from scanned documents using Google ML Kit
- **PDF Generation**: Create, merge, and compress PDF documents
- **Image Enhancement**: Crop, rotate, adjust brightness/contrast, apply filters
- **Document Management**: Organize with folders, tags, favorites
- **Offline-First**: All data stored locally with SQLite
- **Modern UI**: Material 3 design with dark/light theme support

## Architecture

This project follows Clean Architecture with MVVM pattern:

```
lib/
├── core/           # App-wide utilities, themes, constants
├── models/         # Data models
├── repositories/   # Data layer (database, file storage)
├── services/       # Business logic services
├── features/       # Feature modules (scanner, editor, ocr, etc.)
└── widgets/        # Shared widgets
```

## Getting Started

### Prerequisites

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- Android SDK (API 21+)
- iOS 12.0+ (for iOS builds)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd smartscan_ai

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.16+ |
| Language | Dart 3.2+ |
| State Management | Riverpod |
| Database | SQLite (sqflite) |
| OCR | Google ML Kit |
| PDF | pdf + printing |
| Camera | camera package |
| UI | Material 3 |

## Project Structure

- **Clean Architecture**: Separation of concerns with clear layer boundaries
- **MVVM Pattern**: ViewModels handle UI logic, Views are purely presentational
- **Repository Pattern**: Abstract data sources behind repository interfaces
- **Service Layer**: Business logic encapsulated in dedicated services

## Permissions

The app requires:
- Camera (for scanning documents)
- Storage (for saving scans)

## License

This project is proprietary software. All rights reserved.
