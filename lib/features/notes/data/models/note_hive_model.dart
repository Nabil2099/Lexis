import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_type_ids.dart';
import '../../../../core/utils/markdown_utils.dart';
import '../../domain/entities/note_entity.dart';

@HiveType(typeId: HiveTypeIds.note)
class NoteHiveModel extends HiveObject {
  NoteHiveModel({
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

  factory NoteHiveModel.fromEntity(NoteEntity entity) {
    return NoteHiveModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      plainText: entity.plainText,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isPinned: entity.isPinned,
      isArchived: entity.isArchived,
      isDeleted: entity.isDeleted,
      spaceId: entity.spaceId,
      folderId: entity.folderId,
      tagIds: List<String>.from(entity.tagIds),
      type: entity.type,
      status: entity.status,
      wordCount: entity.wordCount,
      backlinks: List<String>.from(entity.backlinks),
      attachments: List<String>.from(entity.attachments),
      summary: entity.summary,
      colorIndex: entity.colorIndex,
      dailyDate: entity.dailyDate,
    );
  }

  factory NoteHiveModel.create({
    required String id,
    String title = '',
    String content = '',
    NoteType type = NoteType.note,
    String? spaceId,
    List<String> tagIds = const [],
  }) {
    final now = DateTime.now();
    final plainText = MarkdownUtils.toPlainText(content);
    return NoteHiveModel(
      id: id,
      title: title,
      content: content,
      plainText: plainText,
      createdAt: now,
      updatedAt: now,
      isPinned: false,
      isArchived: false,
      isDeleted: false,
      spaceId: spaceId,
      folderId: null,
      tagIds: tagIds,
      type: type,
      status: NoteStatus.active,
      wordCount: MarkdownUtils.wordCount(content),
      backlinks: const [],
      attachments: const [],
      summary: null,
      colorIndex: 0,
      dailyDate: null,
    );
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final String plainText;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final DateTime updatedAt;
  @HiveField(6)
  final bool isPinned;
  @HiveField(7)
  final bool isArchived;
  @HiveField(8)
  final bool isDeleted;
  @HiveField(9)
  final String? spaceId;
  @HiveField(10)
  final String? folderId;
  @HiveField(11)
  final List<String> tagIds;
  @HiveField(12)
  final NoteType type;
  @HiveField(13)
  final NoteStatus status;
  @HiveField(14)
  final int wordCount;
  @HiveField(15)
  final List<String> backlinks;
  @HiveField(16)
  final List<String> attachments;
  @HiveField(17)
  final String? summary;
  @HiveField(18)
  final int colorIndex;
  @HiveField(19)
  final String? dailyDate;

  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      plainText: plainText,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
      isArchived: isArchived,
      isDeleted: isDeleted,
      spaceId: spaceId,
      folderId: folderId,
      tagIds: List<String>.from(tagIds),
      type: type,
      status: status,
      wordCount: wordCount,
      backlinks: List<String>.from(backlinks),
      attachments: List<String>.from(attachments),
      summary: summary,
      colorIndex: colorIndex,
      dailyDate: dailyDate,
    );
  }

  NoteHiveModel copyWith({
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
    final nextContent = content ?? this.content;
    return NoteHiveModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: nextContent,
      plainText: plainText ?? MarkdownUtils.toPlainText(nextContent),
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
      wordCount: wordCount ?? MarkdownUtils.wordCount(nextContent),
      backlinks: backlinks ?? this.backlinks,
      attachments: attachments ?? this.attachments,
      summary: summary == _sentinel ? this.summary : summary as String?,
      colorIndex: colorIndex ?? this.colorIndex,
      dailyDate: dailyDate == _sentinel ? this.dailyDate : dailyDate as String?,
    );
  }
}

const Object _sentinel = Object();

class NoteHiveModelAdapter extends TypeAdapter<NoteHiveModel> {
  @override
  final int typeId = HiveTypeIds.note;

  @override
  NoteHiveModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final length = reader.readByte();
    for (var i = 0; i < length; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return NoteHiveModel(
      id: fields[0] as String? ?? '',
      title: fields[1] as String? ?? '',
      content: fields[2] as String? ?? '',
      plainText: fields[3] as String? ?? '',
      createdAt: fields[4] as DateTime? ?? DateTime.now(),
      updatedAt: fields[5] as DateTime? ?? DateTime.now(),
      isPinned: fields[6] as bool? ?? false,
      isArchived: fields[7] as bool? ?? false,
      isDeleted: fields[8] as bool? ?? false,
      spaceId: fields[9] as String?,
      folderId: fields[10] as String?,
      tagIds: (fields[11] as List?)?.cast<String>() ?? const [],
      type: fields[12] as NoteType? ?? NoteType.note,
      status: fields[13] as NoteStatus? ?? NoteStatus.active,
      wordCount: fields[14] as int? ?? 0,
      backlinks: (fields[15] as List?)?.cast<String>() ?? const [],
      attachments: (fields[16] as List?)?.cast<String>() ?? const [],
      summary: fields[17] as String?,
      colorIndex: fields[18] as int? ?? 0,
      dailyDate: fields[19] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NoteHiveModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.plainText)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.isPinned)
      ..writeByte(7)
      ..write(obj.isArchived)
      ..writeByte(8)
      ..write(obj.isDeleted)
      ..writeByte(9)
      ..write(obj.spaceId)
      ..writeByte(10)
      ..write(obj.folderId)
      ..writeByte(11)
      ..write(obj.tagIds)
      ..writeByte(12)
      ..write(obj.type)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.wordCount)
      ..writeByte(15)
      ..write(obj.backlinks)
      ..writeByte(16)
      ..write(obj.attachments)
      ..writeByte(17)
      ..write(obj.summary)
      ..writeByte(18)
      ..write(obj.colorIndex)
      ..writeByte(19)
      ..write(obj.dailyDate);
  }
}
