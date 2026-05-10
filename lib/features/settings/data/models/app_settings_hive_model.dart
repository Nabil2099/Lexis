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
    required this.smartAssistEnabled,
    required this.smartAssistAutoTitle,
    required this.smartAssistAutoSummary,
    required this.smartAssistSuggestTags,
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
      smartAssistEnabled: entity.smartAssistEnabled,
      smartAssistAutoTitle: entity.smartAssistAutoTitle,
      smartAssistAutoSummary: entity.smartAssistAutoSummary,
      smartAssistSuggestTags: entity.smartAssistSuggestTags,
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
  @HiveField(6)
  final bool smartAssistEnabled;
  @HiveField(7)
  final bool smartAssistAutoTitle;
  @HiveField(8)
  final bool smartAssistAutoSummary;
  @HiveField(9)
  final bool smartAssistSuggestTags;

  AppSettingsEntity toEntity() {
    return AppSettingsEntity(
      useMarkdownPreview: useMarkdownPreview,
      showWordCount: showWordCount,
      confirmBeforeDelete: confirmBeforeDelete,
      useTrueBlack: useTrueBlack,
      defaultSpaceId: defaultSpaceId,
      lastOpenedAt: lastOpenedAt,
      smartAssistEnabled: smartAssistEnabled,
      smartAssistAutoTitle: smartAssistAutoTitle,
      smartAssistAutoSummary: smartAssistAutoSummary,
      smartAssistSuggestTags: smartAssistSuggestTags,
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
      smartAssistEnabled: fields[6] as bool? ?? true,
      smartAssistAutoTitle: fields[7] as bool? ?? true,
      smartAssistAutoSummary: fields[8] as bool? ?? true,
      smartAssistSuggestTags: fields[9] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsHiveModel obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.lastOpenedAt)
      ..writeByte(6)
      ..write(obj.smartAssistEnabled)
      ..writeByte(7)
      ..write(obj.smartAssistAutoTitle)
      ..writeByte(8)
      ..write(obj.smartAssistAutoSummary)
      ..writeByte(9)
      ..write(obj.smartAssistSuggestTags);
  }
}
