import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lexis/core/local_storage/hive_boxes.dart';
import 'package:lexis/core/local_storage/hive_init.dart';
import 'package:lexis/features/backup/application/lexis_backup_service.dart';
import 'package:lexis/features/notes/data/models/note_hive_model.dart';
import 'package:lexis/features/notes/domain/entities/note_entity.dart';
import 'package:lexis/features/spaces/data/models/space_hive_model.dart';
import 'package:lexis/features/tags/data/models/tag_hive_model.dart';

void main() {
  late Directory dir;
  const service = LexisBackupService();

  setUp(() async {
    await Hive.close();
    dir = await Directory.systemTemp.createTemp('lexis_backup_test_');
    await HiveInit.init(path: dir.path);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('export/import JSON round trips notes, spaces, and tags', () async {
    final now = DateTime(2026);
    await Hive.box<NoteHiveModel>(HiveBoxes.notes).put(
      'note-1',
      NoteHiveModel(
        id: 'note-1',
        title: 'Project',
        content: 'See [[Reference]]',
        plainText: 'See Reference',
        createdAt: now,
        updatedAt: now,
        isPinned: false,
        isArchived: false,
        isDeleted: false,
        tagIds: const ['tag-1'],
        type: NoteType.note,
        status: NoteStatus.active,
        wordCount: 2,
        backlinks: const [],
        attachments: const [],
        colorIndex: 0,
      ),
    );
    await Hive.box<NoteHiveModel>(HiveBoxes.notes).put(
      'note-2',
      NoteHiveModel(
        id: 'note-2',
        title: 'Reference',
        content: 'Target',
        plainText: 'Target',
        createdAt: now,
        updatedAt: now,
        isPinned: false,
        isArchived: false,
        isDeleted: false,
        tagIds: const [],
        type: NoteType.reference,
        status: NoteStatus.active,
        wordCount: 1,
        backlinks: const [],
        attachments: const [],
        colorIndex: 0,
      ),
    );
    await Hive.box<SpaceHiveModel>(HiveBoxes.spaces).put(
      'space-1',
      SpaceHiveModel(
        id: 'space-1',
        name: 'Work',
        iconCodePoint: 0,
        colorIndex: 0,
        createdAt: now,
        updatedAt: now,
        isArchived: false,
      ),
    );
    await Hive.box<TagHiveModel>(HiveBoxes.tags).put(
      'tag-1',
      TagHiveModel(
        id: 'tag-1',
        name: 'Planning',
        colorHex: '#0E7490',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final json = service.exportJson();
    await service.importJson(json, mode: BackupImportMode.replace);

    expect(Hive.box<NoteHiveModel>(HiveBoxes.notes).length, 2);
    expect(Hive.box<SpaceHiveModel>(HiveBoxes.spaces).length, 1);
    expect(Hive.box<TagHiveModel>(HiveBoxes.tags).length, 1);
    expect(
      Hive.box<NoteHiveModel>(HiveBoxes.notes).get('note-1')!.backlinks,
      ['note-2'],
    );
  });
}
