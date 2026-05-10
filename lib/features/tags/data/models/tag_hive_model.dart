import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_type_ids.dart';
import '../../domain/entities/tag_entity.dart';

@HiveType(typeId: HiveTypeIds.tag)
class TagHiveModel extends HiveObject {
  TagHiveModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TagHiveModel.fromEntity(TagEntity entity) {
    return TagHiveModel(
      id: entity.id,
      name: entity.name,
      colorHex: entity.colorHex,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String colorHex;
  @HiveField(3)
  final DateTime createdAt;
  @HiveField(4)
  final DateTime updatedAt;

  TagEntity toEntity({int noteCount = 0}) {
    return TagEntity(
      id: id,
      name: name,
      colorHex: colorHex,
      createdAt: createdAt,
      updatedAt: updatedAt,
      noteCount: noteCount,
    );
  }

  TagHiveModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TagHiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TagHiveModelAdapter extends TypeAdapter<TagHiveModel> {
  @override
  final int typeId = HiveTypeIds.tag;

  @override
  TagHiveModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final length = reader.readByte();
    for (var i = 0; i < length; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TagHiveModel(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? 'Tag',
      colorHex: fields[2] as String? ?? '#0E7490',
      createdAt: fields[3] as DateTime? ?? DateTime.now(),
      updatedAt: fields[4] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, TagHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorHex)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }
}
