import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lexis/app/lexis_app.dart';
import 'package:lexis/core/local_storage/hive_init.dart';

void main() {
  test('App shell can be constructed after Hive initialization', () async {
    final dir = await Directory.systemTemp.createTemp('lexis_test_');
    await HiveInit.init(path: dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    expect(const LexisApp(), isA<LexisApp>());
  });
}
