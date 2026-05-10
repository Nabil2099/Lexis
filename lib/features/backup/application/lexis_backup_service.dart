import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/local_storage/hive_boxes.dart';
import '../../../core/utils/backlink_utils.dart';
import '../../attachments/data/models/attachment_hive_model.dart';
import '../../notes/data/models/note_hive_model.dart';
import '../../notes/domain/entities/note_entity.dart';
import '../../search/data/models/search_index_hive_model.dart';
import '../../settings/data/models/app_settings_hive_model.dart';
import '../../spaces/data/models/space_hive_model.dart';
import '../../sync/data/models/sync_record_hive_model.dart';
import '../../tags/data/models/tag_hive_model.dart';

enum BackupImportMode { merge, replace }

final lexisBackupServiceProvider = Provider<LexisBackupService>((ref) {
  return LexisBackupService();
});

class LexisBackupService {
  const LexisBackupService();

  Map<String, dynamic> exportMap() {
    return {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'notes': Hive.box<NoteHiveModel>(HiveBoxes.notes)
          .values
          .map(_noteToJson)
          .toList(),
      'trash': Hive.box<NoteHiveModel>(HiveBoxes.trash)
          .values
          .map(_noteToJson)
          .toList(),
      'spaces': Hive.box<SpaceHiveModel>(HiveBoxes.spaces)
          .values
          .map(_spaceToJson)
          .toList(),
      'tags': Hive.box<TagHiveModel>(HiveBoxes.tags)
          .values
          .map(_tagToJson)
          .toList(),
      'settings': Hive.box<AppSettingsHiveModel>(HiveBoxes.settings)
          .values
          .map(_settingsToJson)
          .toList(),
      'attachments': Hive.box<AttachmentHiveModel>(HiveBoxes.attachments)
          .values
          .map((model) => model.toJson())
          .toList(),
      'syncQueue': Hive.box<SyncRecordHiveModel>(HiveBoxes.syncQueue)
          .values
          .map((model) => model.toJson())
          .toList(),
    };
  }

  String exportJson() =>
      const JsonEncoder.withIndent('  ').convert(exportMap());

  Future<void> shareExport() async {
    final json = exportJson();
    final bytes = Uint8List.fromList(utf8.encode(json));
    final date = DateTime.now().toIso8601String().split('T').first;
    await SharePlus.instance.share(
      ShareParams(
        text: 'Lexis backup',
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'application/json',
            name: 'lexis-backup-$date.json',
          ),
        ],
      ),
    );
  }

  Future<bool> importFromPicker({required BackupImportMode mode}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) return false;
    await importJson(utf8.decode(bytes), mode: mode);
    return true;
  }

  Future<void> importJson(
    String json, {
    required BackupImportMode mode,
  }) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    if (mode == BackupImportMode.replace) {
      await Future.wait([
        Hive.box<NoteHiveModel>(HiveBoxes.notes).clear(),
        Hive.box<NoteHiveModel>(HiveBoxes.trash).clear(),
        Hive.box<SpaceHiveModel>(HiveBoxes.spaces).clear(),
        Hive.box<TagHiveModel>(HiveBoxes.tags).clear(),
        Hive.box<AttachmentHiveModel>(HiveBoxes.attachments).clear(),
        Hive.box<SearchIndexHiveModel>(HiveBoxes.searchIndex).clear(),
        Hive.box<SyncRecordHiveModel>(HiveBoxes.syncQueue).clear(),
      ]);
    }

    await _putList<SpaceHiveModel>(
      Hive.box<SpaceHiveModel>(HiveBoxes.spaces),
      data['spaces'],
      _spaceFromJson,
      (model) => model.id,
    );
    await _putList<TagHiveModel>(
      Hive.box<TagHiveModel>(HiveBoxes.tags),
      data['tags'],
      _tagFromJson,
      (model) => model.id,
    );
    await _putList<AttachmentHiveModel>(
      Hive.box<AttachmentHiveModel>(HiveBoxes.attachments),
      data['attachments'],
      (json) => AttachmentHiveModel.fromJson(json),
      (model) => model.id,
    );
    await _putList<SyncRecordHiveModel>(
      Hive.box<SyncRecordHiveModel>(HiveBoxes.syncQueue),
      data['syncQueue'],
      (json) => SyncRecordHiveModel.fromJson(json),
      (model) => model.id,
    );
    await _putList<NoteHiveModel>(
      Hive.box<NoteHiveModel>(HiveBoxes.notes),
      data['notes'],
      _noteFromJson,
      (model) => model.id,
    );
    await _putList<NoteHiveModel>(
      Hive.box<NoteHiveModel>(HiveBoxes.trash),
      data['trash'],
      _noteFromJson,
      (model) => model.id,
    );

    final settings = data['settings'];
    if (settings is List && settings.isNotEmpty) {
      final model = _settingsFromJson(settings.last as Map<String, dynamic>);
      await Hive.box<AppSettingsHiveModel>(HiveBoxes.settings)
          .put('app_settings', model);
    }

    await rebuildDerivedIndexes();
  }

  Future<void> rebuildDerivedIndexes() async {
    final notesBox = Hive.box<NoteHiveModel>(HiveBoxes.notes);
    final searchBox = Hive.box<SearchIndexHiveModel>(HiveBoxes.searchIndex);
    final notes = notesBox.values.map((model) => model.toEntity()).toList();
    final updated = <NoteHiveModel>[];
    for (final model in notesBox.values) {
      final backlinks = BacklinkUtils.resolveLinkedNoteIds(
        source: model.toEntity(),
        notes: notes,
      );
      final next = model.copyWith(backlinks: backlinks);
      updated.add(next);
      await notesBox.put(next.id, next);
      await searchBox.put(
          next.id, SearchIndexHiveModel.fromNote(next.toEntity()));
    }
    for (final model in updated.where((note) => note.isDeleted)) {
      await searchBox.delete(model.id);
    }
  }

  Future<void> _putList<T>(
    Box<T> box,
    Object? value,
    T Function(Map<String, dynamic>) fromJson,
    String Function(T) idOf,
  ) async {
    if (value is! List) return;
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        final model = fromJson(item);
        await box.put(idOf(model), model);
      }
    }
  }

  Map<String, dynamic> _noteToJson(NoteHiveModel note) => {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'plainText': note.plainText,
        'createdAt': note.createdAt.toIso8601String(),
        'updatedAt': note.updatedAt.toIso8601String(),
        'isPinned': note.isPinned,
        'isArchived': note.isArchived,
        'isDeleted': note.isDeleted,
        'spaceId': note.spaceId,
        'folderId': note.folderId,
        'tagIds': note.tagIds,
        'type': note.type.name,
        'status': note.status.name,
        'wordCount': note.wordCount,
        'backlinks': note.backlinks,
        'attachments': note.attachments,
        'summary': note.summary,
        'colorIndex': note.colorIndex,
        'dailyDate': note.dailyDate,
      };

  NoteHiveModel _noteFromJson(Map<String, dynamic> json) {
    return NoteHiveModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      plainText: json['plainText'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      spaceId: json['spaceId'] as String?,
      folderId: json['folderId'] as String?,
      tagIds: (json['tagIds'] as List?)?.cast<String>() ?? const [],
      type: _enumByName(NoteType.values, json['type'] as String?) ??
          NoteType.note,
      status: _enumByName(NoteStatus.values, json['status'] as String?) ??
          NoteStatus.active,
      wordCount: json['wordCount'] as int? ?? 0,
      backlinks: (json['backlinks'] as List?)?.cast<String>() ?? const [],
      attachments: (json['attachments'] as List?)?.cast<String>() ?? const [],
      summary: json['summary'] as String?,
      colorIndex: json['colorIndex'] as int? ?? 0,
      dailyDate: json['dailyDate'] as String?,
    );
  }

  Map<String, dynamic> _spaceToJson(SpaceHiveModel space) => {
        'id': space.id,
        'name': space.name,
        'description': space.description,
        'iconCodePoint': space.iconCodePoint,
        'colorIndex': space.colorIndex,
        'createdAt': space.createdAt.toIso8601String(),
        'updatedAt': space.updatedAt.toIso8601String(),
        'isArchived': space.isArchived,
      };

  SpaceHiveModel _spaceFromJson(Map<String, dynamic> json) => SpaceHiveModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Space',
        description: json['description'] as String?,
        iconCodePoint: json['iconCodePoint'] as int? ?? 0,
        colorIndex: json['colorIndex'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        isArchived: json['isArchived'] as bool? ?? false,
      );

  Map<String, dynamic> _tagToJson(TagHiveModel tag) => {
        'id': tag.id,
        'name': tag.name,
        'colorHex': tag.colorHex,
        'createdAt': tag.createdAt.toIso8601String(),
        'updatedAt': tag.updatedAt.toIso8601String(),
      };

  TagHiveModel _tagFromJson(Map<String, dynamic> json) => TagHiveModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Tag',
        colorHex: json['colorHex'] as String? ?? '#0E7490',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> _settingsToJson(AppSettingsHiveModel settings) => {
        'useMarkdownPreview': settings.useMarkdownPreview,
        'showWordCount': settings.showWordCount,
        'confirmBeforeDelete': settings.confirmBeforeDelete,
        'useTrueBlack': settings.useTrueBlack,
        'defaultSpaceId': settings.defaultSpaceId,
        'lastOpenedAt': settings.lastOpenedAt.toIso8601String(),
        'smartAssistEnabled': settings.smartAssistEnabled,
        'smartAssistAutoTitle': settings.smartAssistAutoTitle,
        'smartAssistAutoSummary': settings.smartAssistAutoSummary,
        'smartAssistSuggestTags': settings.smartAssistSuggestTags,
        'encryptionKeyReady': settings.encryptionKeyReady,
        'appLockEnabled': settings.appLockEnabled,
        'lockAfterMinutes': settings.lockAfterMinutes,
        'syncEnabled': settings.syncEnabled,
        'syncLastSyncedAt': settings.syncLastSyncedAt?.toIso8601String(),
      };

  AppSettingsHiveModel _settingsFromJson(Map<String, dynamic> json) {
    return AppSettingsHiveModel(
      useMarkdownPreview: json['useMarkdownPreview'] as bool? ?? false,
      showWordCount: json['showWordCount'] as bool? ?? true,
      confirmBeforeDelete: json['confirmBeforeDelete'] as bool? ?? true,
      useTrueBlack: json['useTrueBlack'] as bool? ?? true,
      defaultSpaceId: json['defaultSpaceId'] as String? ?? '',
      lastOpenedAt: DateTime.tryParse(json['lastOpenedAt'] as String? ?? '') ??
          DateTime.now(),
      smartAssistEnabled: json['smartAssistEnabled'] as bool? ?? true,
      smartAssistAutoTitle: json['smartAssistAutoTitle'] as bool? ?? true,
      smartAssistAutoSummary: json['smartAssistAutoSummary'] as bool? ?? true,
      smartAssistSuggestTags: json['smartAssistSuggestTags'] as bool? ?? true,
      encryptionKeyReady: json['encryptionKeyReady'] as bool? ?? false,
      appLockEnabled: json['appLockEnabled'] as bool? ?? false,
      lockAfterMinutes: json['lockAfterMinutes'] as int? ?? 5,
      syncEnabled: json['syncEnabled'] as bool? ?? false,
      syncLastSyncedAt:
          DateTime.tryParse(json['syncLastSyncedAt'] as String? ?? ''),
    );
  }

  T? _enumByName<T extends Enum>(List<T> values, String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
