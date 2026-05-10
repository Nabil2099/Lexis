import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_type_ids.dart';
import '../../domain/entities/sync_record_entity.dart';

@HiveType(typeId: HiveTypeIds.syncRecord)
class SyncRecordHiveModel extends HiveObject {
  SyncRecordHiveModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.createdAt,
    this.syncedAt,
  });

  factory SyncRecordHiveModel.fromEntity(SyncRecordEntity entity) {
    return SyncRecordHiveModel(
      id: entity.id,
      entityType: entity.entityType,
      entityId: entity.entityId,
      action: entity.action,
      createdAt: entity.createdAt,
      syncedAt: entity.syncedAt,
    );
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String entityType;
  @HiveField(2)
  final String entityId;
  @HiveField(3)
  final String action;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final DateTime? syncedAt;

  SyncRecordEntity toEntity() {
    return SyncRecordEntity(
      id: id,
      entityType: entityType,
      entityId: entityId,
      action: action,
      createdAt: createdAt,
      syncedAt: syncedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'action': action,
      'createdAt': createdAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  factory SyncRecordHiveModel.fromJson(Map<String, dynamic> json) {
    return SyncRecordHiveModel(
      id: json['id'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      action: json['action'] as String? ?? 'update',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      syncedAt: DateTime.tryParse(json['syncedAt'] as String? ?? ''),
    );
  }
}

class SyncRecordHiveModelAdapter extends TypeAdapter<SyncRecordHiveModel> {
  @override
  final int typeId = HiveTypeIds.syncRecord;

  @override
  SyncRecordHiveModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final length = reader.readByte();
    for (var i = 0; i < length; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SyncRecordHiveModel(
      id: fields[0] as String? ?? '',
      entityType: fields[1] as String? ?? '',
      entityId: fields[2] as String? ?? '',
      action: fields[3] as String? ?? 'update',
      createdAt: fields[4] as DateTime? ?? DateTime.now(),
      syncedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncRecordHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.action)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.syncedAt);
  }
}
