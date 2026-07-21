import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smartscan_ai/core/constants/app_constants.dart';

/// Singleton service managing the SQLite database.
/// Handles initialization, migrations, and provides the database instance.
class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  /// Gets the database instance, initializing if needed.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initializes the database on app start.
  Future<void> initialize() async {
    _database = await _initDatabase();
  }

  /// Creates and configures the database.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates all tables on first install.
  Future<void> _onCreate(Database db, int version) async {
    // Documents table
    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        folder_id TEXT,
        category TEXT,
        tags TEXT,
        is_favorite INTEGER DEFAULT 0,
        thumbnail_path TEXT,
        ocr_text TEXT,
        page_count INTEGER DEFAULT 0,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE SET NULL
      )
    ''');

    // Pages table
    await db.execute('''
      CREATE TABLE pages (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        image_path TEXT NOT NULL,
        thumbnail_path TEXT,
        page_number INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        ocr_text TEXT,
        rotation REAL DEFAULT 0,
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''');

    // Folders table
    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        color TEXT
      )
    ''');

    // Settings table (key-value store)
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes for performance
    await db.execute(
      'CREATE INDEX idx_documents_folder ON documents(folder_id)',
    );
    await db.execute(
      'CREATE INDEX idx_documents_favorite ON documents(is_favorite)',
    );
    await db.execute(
      'CREATE INDEX idx_documents_created ON documents(created_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_pages_document ON pages(document_id)',
    );
    await db.execute(
      'CREATE INDEX idx_pages_number ON pages(document_id, page_number)',
    );
  }

  /// Handles database schema upgrades.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
