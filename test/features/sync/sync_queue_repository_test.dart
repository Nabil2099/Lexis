import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lexis/core/local_storage/hive_init.dart';
import 'package:lexis/features/sync/data/repositories/sync_queue_repository.dart';

void main() {
  late Directory dir;

  setUp(() async {
    await Hive.close();
    dir = await Directory.systemTemp.createTemp('lexis_sync_test_');
    await HiveInit.init(path: dir.path);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('record stores local mutation metadata', () async {
    final queue = SyncQueueRepository();
    await queue.record(
        entityType: 'note', entityId: 'note-1', action: 'update');

    final records = queue.all();

    expect(records, hasLength(1));
    expect(records.single.entityType, 'note');
    expect(records.single.entityId, 'note-1');
    expect(records.single.action, 'update');
  });
}
