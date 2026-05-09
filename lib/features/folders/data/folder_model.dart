import '../../../core/database/app_database.dart';

class Folder {
  final int id;
  final String name;
  final DateTime createdAt;
  final int noteCount;

  Folder({
    required this.id,
    required this.name,
    required this.createdAt,
    this.noteCount = 0,
  });

  factory Folder.fromDrift(FoldersTableData data, {int noteCount = 0}) {
    return Folder(
      id: data.id,
      name: data.name,
      createdAt: data.createdAt,
      noteCount: noteCount,
    );
  }

  Folder copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    int? noteCount,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      noteCount: noteCount ?? this.noteCount,
    );
  }
}
