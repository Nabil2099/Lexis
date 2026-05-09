import '../../../core/database/app_database.dart';

class Note {
  final int id;
  final String uuid;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isArchived;
  final int? folderId;
  final List<int> tagIds;

  Note({
    required this.id,
    required this.uuid,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.isArchived,
    this.folderId,
    this.tagIds = const [],
  });

  factory Note.fromDrift(NotesTableData data, {List<int> tagIds = const []}) {
    return Note(
      id: data.id,
      uuid: data.uuid,
      title: data.title,
      content: data.content,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isPinned: data.isPinned,
      isArchived: data.isArchived,
      folderId: data.folderId,
      tagIds: tagIds,
    );
  }

  String get plainPreview {
    return content
        .replaceAll(RegExp(r'[#*_`\[\]()]'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
  }

  Note copyWith({
    int? id,
    String? uuid,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isArchived,
    int? folderId,
    List<int>? tagIds,
  }) {
    return Note(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      folderId: folderId ?? this.folderId,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}
