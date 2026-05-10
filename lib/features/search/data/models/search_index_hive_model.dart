import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_type_ids.dart';
import '../../../notes/domain/entities/note_entity.dart';

@HiveType(typeId: HiveTypeIds.searchIndex)
class SearchIndexHiveModel extends HiveObject {
  SearchIndexHiveModel({
    required this.noteId,
    required this.titleIndex,
    required this.contentIndex,
    required this.tagIds,
    required this.type,
    required this.updatedAt,
    this.spaceId,
  });

  factory SearchIndexHiveModel.fromNote(NoteEntity note) {
    return SearchIndexHiveModel(
      noteId: note.id,
      titleIndex: note.title.toLowerCase(),
      contentIndex: note.plainText.toLowerCase(),
      tagIds: note.tagIds,
      spaceId: note.spaceId,
      type: note.type,
      updatedAt: note.updatedAt,
    );
  }

  @HiveField(0)
  final String noteId;
  @HiveField(1)
  final String titleIndex;
  @HiveField(2)
  final String contentIndex;
  @HiveField(3)
  final List<String> tagIds;
  @HiveField(4)
  final String? spaceId;
  @HiveField(5)
  final NoteType type;
  @HiveField(6)
  final DateTime updatedAt;
}

class SearchIndexHiveModelAdapter extends TypeAdapter<SearchIndexHiveModel> {
  @override
  final int typeId = HiveTypeIds.searchIndex;

  @override
  SearchIndexHiveModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final length = reader.readByte();
    for (var i = 0; i < length; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SearchIndexHiveModel(
      noteId: fields[0] as String? ?? '',
      titleIndex: fields[1] as String? ?? '',
      contentIndex: fields[2] as String? ?? '',
      tagIds: (fields[3] as List?)?.cast<String>() ?? const [],
      spaceId: fields[4] as String?,
      type: fields[5] as NoteType? ?? NoteType.note,
      updatedAt: fields[6] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, SearchIndexHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.noteId)
      ..writeByte(1)
      ..write(obj.titleIndex)
      ..writeByte(2)
      ..write(obj.contentIndex)
      ..writeByte(3)
      ..write(obj.tagIds)
      ..writeByte(4)
      ..write(obj.spaceId)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }
}
