class SpaceEntity {
  const SpaceEntity({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorIndex,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
    this.description,
    this.noteCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final int iconCodePoint;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final int noteCount;

  SpaceEntity copyWith({
    String? id,
    String? name,
    Object? description = _sentinel,
    int? iconCodePoint,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    int? noteCount,
  }) {
    return SpaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          description == _sentinel ? this.description : description as String?,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      noteCount: noteCount ?? this.noteCount,
    );
  }
}

const Object _sentinel = Object();
