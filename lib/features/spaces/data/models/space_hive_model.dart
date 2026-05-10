import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_type_ids.dart';
import '../../domain/entities/space_entity.dart';

@HiveType(typeId: HiveTypeIds.space)
class SpaceHiveModel extends HiveObject {
  SpaceHiveModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorIndex,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
    this.description,
  });

  factory SpaceHiveModel.fromEntity(SpaceEntity entity) {
    return SpaceHiveModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      iconCodePoint: entity.iconCodePoint,
      colorIndex: entity.colorIndex,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isArchived: entity.isArchived,
    );
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final int iconCodePoint;
  @HiveField(4)
  final int colorIndex;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime updatedAt;
  @HiveField(7)
  final bool isArchived;

  SpaceEntity toEntity({int noteCount = 0}) {
    return SpaceEntity(
      id: id,
      name: name,
      description: description,
      iconCodePoint: iconCodePoint,
      colorIndex: colorIndex,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived,
      noteCount: noteCount,
    );
  }

  SpaceHiveModel copyWith({
    String? id,
    String? name,
    Object? description = _sentinel,
    int? iconCodePoint,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return SpaceHiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          description == _sentinel ? this.description : description as String?,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

const Object _sentinel = Object();

class SpaceHiveModelAdapter extends TypeAdapter<SpaceHiveModel> {
  @override
  final int typeId = HiveTypeIds.space;

  @override
  SpaceHiveModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final length = reader.readByte();
    for (var i = 0; i < length; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SpaceHiveModel(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? 'Space',
      description: fields[2] as String?,
      iconCodePoint: fields[3] as int? ?? 0,
      colorIndex: fields[4] as int? ?? 0,
      createdAt: fields[5] as DateTime? ?? DateTime.now(),
      updatedAt: fields[6] as DateTime? ?? DateTime.now(),
      isArchived: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, SpaceHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconCodePoint)
      ..writeByte(4)
      ..write(obj.colorIndex)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isArchived);
  }
}
