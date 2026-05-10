class AttachmentEntity {
  const AttachmentEntity({
    required this.id,
    required this.noteId,
    required this.fileName,
    required this.localPath,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
  });

  final String id;
  final String noteId;
  final String fileName;
  final String localPath;
  final String mimeType;
  final int sizeBytes;
  final DateTime createdAt;

  AttachmentEntity copyWith({
    String? id,
    String? noteId,
    String? fileName,
    String? localPath,
    String? mimeType,
    int? sizeBytes,
    DateTime? createdAt,
  }) {
    return AttachmentEntity(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      fileName: fileName ?? this.fileName,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
