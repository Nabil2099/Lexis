class TagEntity {
  const TagEntity({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
    this.noteCount = 0,
  });

  final String id;
  final String name;
  final String colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int noteCount;

  TagEntity copyWith({
    String? id,
    String? name,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? noteCount,
  }) {
    return TagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      noteCount: noteCount ?? this.noteCount,
    );
  }
}
