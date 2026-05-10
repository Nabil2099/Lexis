import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_type_ids.dart';
import '../../domain/entities/attachment_entity.dart';

@HiveType(typeId: HiveTypeIds.attachment)
class AttachmentHiveModel extends HiveObject {
  AttachmentHiveModel({
    required this.id,
    required this.noteId,
    required this.fileName,
    required this.localPath,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
  });

  factory AttachmentHiveModel.fromEntity(AttachmentEntity entity) {
    return AttachmentHiveModel(
      id: entity.id,
      noteId: entity.noteId,
      fileName: entity.fileName,
      localPath: entity.localPath,
      mimeType: entity.mimeType,
      sizeBytes: entity.sizeBytes,
      createdAt: entity.createdAt,
    );
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String noteId;
  @HiveField(2)
  final String fileName;
  @HiveField(3)
  final String localPath;
  @HiveField(4)
  final String mimeType;
  @HiveField(5)
  final int sizeBytes;
  @HiveField(6)
  final DateTime createdAt;

  AttachmentEntity toEntity() {
    return AttachmentEntity(
      id: id,
      noteId: noteId,
      fileName: fileName,
      localPath: localPath,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noteId': noteId,
      'fileName': fileName,
      'localPath': localPath,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AttachmentHiveModel.fromJson(Map<String, dynamic> json) {
    return AttachmentHiveModel(
      id: json['id'] as String? ?? '',
      noteId: json['noteId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? 'Attachment',
      localPath: json['localPath'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class AttachmentHiveModelAdapter extends TypeAdapter<AttachmentHiveModel> {
  @override
  final int typeId = HiveTypeIds.attachment;

  @override
  AttachmentHiveModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final length = reader.readByte();
    for (var i = 0; i < length; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AttachmentHiveModel(
      id: fields[0] as String? ?? '',
      noteId: fields[1] as String? ?? '',
      fileName: fields[2] as String? ?? 'Attachment',
      localPath: fields[3] as String? ?? '',
      mimeType: fields[4] as String? ?? 'application/octet-stream',
      sizeBytes: fields[5] as int? ?? 0,
      createdAt: fields[6] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, AttachmentHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.noteId)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.localPath)
      ..writeByte(4)
      ..write(obj.mimeType)
      ..writeByte(5)
      ..write(obj.sizeBytes)
      ..writeByte(6)
      ..write(obj.createdAt);
  }
}
