import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_type_ids.dart';
import '../../domain/entities/app_settings_entity.dart';

@HiveType(typeId: HiveTypeIds.appSettings)
class AppSettingsHiveModel extends HiveObject {
  AppSettingsHiveModel({
    required this.useMarkdownPreview,
    required this.showWordCount,
    required this.confirmBeforeDelete,
    required this.useTrueBlack,
    required this.defaultSpaceId,
    required this.lastOpenedAt,
  });

  factory AppSettingsHiveModel.defaults() =>
      AppSettingsHiveModel.fromEntity(AppSettingsEntity.defaults());

  factory AppSettingsHiveModel.fromEntity(AppSettingsEntity entity) {
    return AppSettingsHiveModel(
      useMarkdownPreview: entity.useMarkdownPreview,
      showWordCount: entity.showWordCount,
      confirmBeforeDelete: entity.confirmBeforeDelete,
      useTrueBlack: entity.useTrueBlack,
      defaultSpaceId: entity.defaultSpaceId,
      lastOpenedAt: entity.lastOpenedAt,
    );
  }

  @HiveField(0)
  final bool useMarkdownPreview;
  @HiveField(1)
  final bool showWordCount;
  @HiveField(2)
  final bool confirmBeforeDelete;
  @HiveField(3)
  final bool useTrueBlack;
  @HiveField(4)
  final String defaultSpaceId;
  @HiveField(5)
  final DateTime lastOpenedAt;

  AppSettingsEntity toEntity() {
    return AppSettingsEntity(
      useMarkdownPreview: useMarkdownPreview,
      showWordCount: showWordCount,
      confirmBeforeDelete: confirmBeforeDelete,
      useTrueBlack: useTrueBlack,
      defaultSpaceId: defaultSpaceId,
      lastOpenedAt: lastOpenedAt,
    );
  }
}

class AppSettingsHiveModelAdapter extends TypeAdapter<AppSettingsHiveModel> {
  @override
  final int typeId = HiveTypeIds.appSettings;

  @override
  AppSettingsHiveModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final length = reader.readByte();
    for (var i = 0; i < length; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AppSettingsHiveModel(
      useMarkdownPreview: fields[0] as bool? ?? false,
      showWordCount: fields[1] as bool? ?? true,
      confirmBeforeDelete: fields[2] as bool? ?? true,
      useTrueBlack: fields[3] as bool? ?? true,
      defaultSpaceId: fields[4] as String? ?? '',
      lastOpenedAt: fields[5] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.useMarkdownPreview)
      ..writeByte(1)
      ..write(obj.showWordCount)
      ..writeByte(2)
      ..write(obj.confirmBeforeDelete)
      ..writeByte(3)
      ..write(obj.useTrueBlack)
      ..writeByte(4)
      ..write(obj.defaultSpaceId)
      ..writeByte(5)
      ..write(obj.lastOpenedAt);
  }
}
