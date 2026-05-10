import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_type_ids.dart';
import '../../domain/entities/note_entity.dart';

class NoteTypeAdapter extends TypeAdapter<NoteType> {
  @override
  final int typeId = HiveTypeIds.noteType;

  @override
  NoteType read(BinaryReader reader) {
    final value = reader.readString();
    return NoteType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NoteType.note,
    );
  }

  @override
  void write(BinaryWriter writer, NoteType obj) => writer.writeString(obj.name);
}

class NoteStatusAdapter extends TypeAdapter<NoteStatus> {
  @override
  final int typeId = HiveTypeIds.noteStatus;

  @override
  NoteStatus read(BinaryReader reader) {
    final value = reader.readString();
    return NoteStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => NoteStatus.active,
    );
  }

  @override
  void write(BinaryWriter writer, NoteStatus obj) =>
      writer.writeString(obj.name);
}
