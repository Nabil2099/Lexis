enum NoteType {
  note,
  idea,
  task,
  journal,
  reference,
  codeSnippet,
}

enum NoteStatus {
  active,
  draft,
  reviewed,
  archived,
  deleted,
}

extension NoteTypeLabel on NoteType {
  String get label {
    return switch (this) {
      NoteType.note => 'Note',
      NoteType.idea => 'Idea',
      NoteType.task => 'Task',
      NoteType.journal => 'Journal',
      NoteType.reference => 'Reference',
      NoteType.codeSnippet => 'Code',
    };
  }
}

class NoteEntity {
  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.plainText,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.isArchived,
    required this.isDeleted,
    required this.tagIds,
    required this.type,
    required this.status,
    required this.wordCount,
    required this.backlinks,
    required this.attachments,
    required this.colorIndex,
    this.spaceId,
    this.folderId,
    this.summary,
    this.dailyDate,
  });

  final String id;
  final String title;
  final String content;
  final String plainText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isArchived;
  final bool isDeleted;
  final String? spaceId;
  final String? folderId;
  final List<String> tagIds;
  final NoteType type;
  final NoteStatus status;
  final int wordCount;
  final List<String> backlinks;
  final List<String> attachments;
  final String? summary;
  final int colorIndex;
  final String? dailyDate;

  String get displayTitle => title.trim().isEmpty ? 'Untitled' : title.trim();

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? plainText,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isArchived,
    bool? isDeleted,
    Object? spaceId = _sentinel,
    Object? folderId = _sentinel,
    List<String>? tagIds,
    NoteType? type,
    NoteStatus? status,
    int? wordCount,
    List<String>? backlinks,
    List<String>? attachments,
    Object? summary = _sentinel,
    int? colorIndex,
    Object? dailyDate = _sentinel,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      plainText: plainText ?? this.plainText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      spaceId: spaceId == _sentinel ? this.spaceId : spaceId as String?,
      folderId: folderId == _sentinel ? this.folderId : folderId as String?,
      tagIds: tagIds ?? this.tagIds,
      type: type ?? this.type,
      status: status ?? this.status,
      wordCount: wordCount ?? this.wordCount,
      backlinks: backlinks ?? this.backlinks,
      attachments: attachments ?? this.attachments,
      summary: summary == _sentinel ? this.summary : summary as String?,
      colorIndex: colorIndex ?? this.colorIndex,
      dailyDate: dailyDate == _sentinel ? this.dailyDate : dailyDate as String?,
    );
  }
}

const Object _sentinel = Object();
