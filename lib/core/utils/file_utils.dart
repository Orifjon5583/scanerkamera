import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_ai/core/constants/app_constants.dart';

/// Utility class for file system operations.
class FileUtils {
  FileUtils._();

  /// Gets the application documents directory.
  static Future<Directory> getAppDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  /// Creates a directory if it doesn't exist.
  static Future<Directory> ensureDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Gets file size in bytes.
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// Formats file size to human-readable string.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Deletes a file safely.
  static Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Deletes a directory and its contents safely.
  static Future<bool> deleteDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Lists files in a directory with optional extension filter.
  static Future<List<File>> listFiles(
    String directoryPath, {
    String? extension,
  }) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File) {
        if (extension == null || entity.path.endsWith(extension)) {
          files.add(entity);
        }
      }
    }
    return files;
  }

  /// Copies a directory recursively.
  static Future<void> copyDirectory(String source, String destination) async {
    final sourceDir = Directory(source);
    final destDir = Directory(destination);

    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    await for (final entity in sourceDir.list(recursive: false)) {
      final newPath =
          '${destDir.path}/${entity.path.split(Platform.pathSeparator).last}';
      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await copyDirectory(entity.path, newPath);
      }
    }
  }

  /// Gets the temporary directory for processing.
  static Future<Directory> getTempDirectory() async {
    final temp = await getTemporaryDirectory();
    final processDir = Directory('${temp.path}/smartscan_processing');
    if (!await processDir.exists()) {
      await processDir.create(recursive: true);
    }
    return processDir;
  }

  /// Cleans temporary files.
  static Future<void> cleanTempFiles() async {
    try {
      final temp = await getTemporaryDirectory();
      final processDir = Directory('${temp.path}/smartscan_processing');
      if (await processDir.exists()) {
        await processDir.delete(recursive: true);
      }
    } catch (_) {
      // Silently fail on cleanup
    }
  }
}
