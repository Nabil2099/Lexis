import 'package:hive_flutter/hive_flutter.dart';

import '../../features/notes/data/models/note_hive_model.dart';
import '../../features/notes/data/models/note_type_adapter.dart';
import '../../features/search/data/models/search_index_hive_model.dart';
import '../../features/settings/data/models/app_settings_hive_model.dart';
import '../../features/spaces/data/models/space_hive_model.dart';
import '../../features/tags/data/models/tag_hive_model.dart';
import 'hive_boxes.dart';

class HiveInit {
  const HiveInit._();

  static Future<void> init({String? path}) async {
    if (path == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(path);
    }

    _registerAdapters();

    await Future.wait([
      Hive.openBox<NoteHiveModel>(HiveBoxes.notes),
      Hive.openBox<NoteHiveModel>(HiveBoxes.trash),
      Hive.openBox<SpaceHiveModel>(HiveBoxes.spaces),
      Hive.openBox<TagHiveModel>(HiveBoxes.tags),
      Hive.openBox<AppSettingsHiveModel>(HiveBoxes.settings),
      Hive.openBox<SearchIndexHiveModel>(HiveBoxes.searchIndex),
    ]);
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(NoteTypeAdapter().typeId)) {
      Hive.registerAdapter(NoteTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(NoteStatusAdapter().typeId)) {
      Hive.registerAdapter(NoteStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(NoteHiveModelAdapter().typeId)) {
      Hive.registerAdapter(NoteHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(SpaceHiveModelAdapter().typeId)) {
      Hive.registerAdapter(SpaceHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(TagHiveModelAdapter().typeId)) {
      Hive.registerAdapter(TagHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppSettingsHiveModelAdapter().typeId)) {
      Hive.registerAdapter(AppSettingsHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(SearchIndexHiveModelAdapter().typeId)) {
      Hive.registerAdapter(SearchIndexHiveModelAdapter());
    }
  }
}
