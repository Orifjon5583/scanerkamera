import 'package:sqflite/sqflite.dart';
import 'package:smartscan_ai/core/services/database_service.dart';

/// Repository for application settings persistence.
/// Uses a key-value store pattern backed by SQLite.
class SettingsRepository {
  final DatabaseService _dbService;

  SettingsRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  /// Gets a setting value by key.
  Future<String?> getSetting(String key) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  /// Sets a setting value.
  Future<void> setSetting(String key, String value) async {
    final db = await _dbService.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes a setting by key.
  Future<void> deleteSetting(String key) async {
    final db = await _dbService.database;
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// Gets all settings as a map.
  Future<Map<String, String>> getAllSettings() async {
    final db = await _dbService.database;
    final maps = await db.query('settings');
    return Map.fromEntries(
      maps.map((m) => MapEntry(m['key'] as String, m['value'] as String)),
    );
  }
}
