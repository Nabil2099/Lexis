import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lexis/core/local_storage/hive_init.dart';
import 'package:lexis/features/daily_notes/application/daily_notes_service.dart';

void main() {
  late Directory dir;
  late ProviderContainer container;

  setUp(() async {
    await Hive.close();
    dir = await Directory.systemTemp.createTemp('lexis_daily_test_');
    await HiveInit.init(path: dir.path);
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('getOrCreate returns one canonical note per date', () async {
    final service = container.read(dailyNotesServiceProvider);
    final first = await service.getOrCreate(DateTime(2026, 5, 10));
    final second = await service.getOrCreate(DateTime(2026, 5, 10));

    expect(first.id, second.id);
    expect(first.dailyDate, '2026-05-10');
  });
}
