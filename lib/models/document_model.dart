/// Represents a scanned document with its metadata and pages.
class DocumentModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PageModel> pages;
  final String? folderId;
  final String? category;
  final List<String> tags;
  final bool isFavorite;
  final String? thumbnailPath;
  final String? ocrText;
  final int pageCount;

  const DocumentModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.pages,
    this.folderId,
    this.category,
    this.tags = const [],
    this.isFavorite = false,
    this.thumbnailPath,
    this.ocrText,
    this.pageCount = 0,
  });

  /// Creates a copy of this document with optional field overrides.
  DocumentModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PageModel>? pages,
    String? folderId,
    String? category,
    List<String>? tags,
    bool? isFavorite,
    String? thumbnailPath,
    String? ocrText,
    int? pageCount,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pages: pages ?? this.pages,
      folderId: folderId ?? this.folderId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      ocrText: ocrText ?? this.ocrText,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  /// Converts the document to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'folder_id': folderId,
      'category': category,
      'tags': tags.join(','),
      'is_favorite': isFavorite ? 1 : 0,
      'thumbnail_path': thumbnailPath,
      'ocr_text': ocrText,
      'page_count': pageCount,
    };
  }

  /// Creates a document from a database map.
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      pages: [],
      folderId: map['folder_id'] as String?,
      category: map['category'] as String?,
      tags: (map['tags'] as String?)?.isNotEmpty == true
          ? (map['tags'] as String).split(',')
          : [],
      isFavorite: (map['is_favorite'] as int?) == 1,
      thumbnailPath: map['thumbnail_path'] as String?,
      ocrText: map['ocr_text'] as String?,
      pageCount: map['page_count'] as int? ?? 0,
    );
  }
}

/// Represents a single page within a document.
class PageModel {
  final String id;
  final String documentId;
  final String imagePath;
  final String? thumbnailPath;
  final int pageNumber;
  final DateTime createdAt;
  final String? ocrText;
  final double? rotation;

  const PageModel({
    required this.id,
    required this.documentId,
    required this.imagePath,
    this.thumbnailPath,
    required this.pageNumber,
    required this.createdAt,
    this.ocrText,
    this.rotation,
  });

  /// Creates a copy with optional field overrides.
  PageModel copyWith({
    String? id,
    String? documentId,
    String? imagePath,
    String? thumbnailPath,
    int? pageNumber,
    DateTime? createdAt,
    String? ocrText,
    double? rotation,
  }) {
    return PageModel(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
      ocrText: ocrText ?? this.ocrText,
      rotation: rotation ?? this.rotation,
    );
  }

  /// Converts the page to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_id': documentId,
      'image_path': imagePath,
      'thumbnail_path': thumbnailPath,
      'page_number': pageNumber,
      'created_at': createdAt.toIso8601String(),
      'ocr_text': ocrText,
      'rotation': rotation,
    };
  }

  /// Creates a page from a database map.
  factory PageModel.fromMap(Map<String, dynamic> map) {
    return PageModel(
      id: map['id'] as String,
      documentId: map['document_id'] as String,
      imagePath: map['image_path'] as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      pageNumber: map['page_number'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      ocrText: map['ocr_text'] as String?,
      rotation: map['rotation'] as double?,
    );
  }
}
