import 'package:smartscan_ai/core/services/database_service.dart';
import 'package:smartscan_ai/models/folder_model.dart';

/// Repository for folder CRUD operations.
class FolderRepository {
  final DatabaseService _dbService;

  FolderRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  /// Retrieves all folders with document counts.
  Future<List<FolderModel>> getAllFolders() async {
    final db = await _dbService.database;
    final maps = await db.rawQuery('''
      SELECT f.*, COUNT(d.id) as document_count
      FROM folders f
      LEFT JOIN documents d ON d.folder_id = f.id
      GROUP BY f.id
      ORDER BY f.name ASC
    ''');
    return maps.map((map) => FolderModel.fromMap(map)).toList();
  }

  /// Retrieves a single folder by ID.
  Future<FolderModel?> getFolder(String id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FolderModel.fromMap(maps.first);
  }

  /// Inserts a new folder.
  Future<void> insertFolder(FolderModel folder) async {
    final db = await _dbService.database;
    await db.insert('folders', folder.toMap());
  }

  /// Updates an existing folder.
  Future<void> updateFolder(FolderModel folder) async {
    final db = await _dbService.database;
    await db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  /// Deletes a folder by ID.
  /// Documents in this folder will have their folder_id set to null.
  Future<void> deleteFolder(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Checks if a folder name already exists.
  Future<bool> folderExists(String name) async {
    final db = await _dbService.database;
    final result = await db.query(
      'folders',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }
}
