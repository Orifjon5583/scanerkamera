/// Represents a folder for organizing documents.
class FolderModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final int documentCount;
  final String? color;

  const FolderModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.documentCount = 0,
    this.color,
  });

  /// Creates a copy with optional field overrides.
  FolderModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? documentCount,
    String? color,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      documentCount: documentCount ?? this.documentCount,
      color: color ?? this.color,
    );
  }

  /// Converts to a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'color': color,
    };
  }

  /// Creates a folder from a database map.
  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      documentCount: map['document_count'] as int? ?? 0,
      color: map['color'] as String?,
    );
  }
}
