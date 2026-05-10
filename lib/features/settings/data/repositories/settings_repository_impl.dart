import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_boxes.dart';
import '../../../notes/data/models/note_hive_model.dart';
import '../../../search/data/models/search_index_hive_model.dart';
import '../../../spaces/data/models/space_hive_model.dart';
import '../../../tags/data/models/tag_hive_model.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings_hive_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(SettingsLocalDataSource());
});

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource);

  final SettingsLocalDataSource _dataSource;

  @override
  Future<AppSettingsEntity> get() async {
    final model = _dataSource.get();
    final updated = AppSettingsHiveModel.fromEntity(
        model.toEntity().copyWith(lastOpenedAt: DateTime.now()));
    await _dataSource.put(updated);
    return updated.toEntity();
  }

  @override
  Future<AppSettingsEntity> update(AppSettingsEntity settings) async {
    final model = AppSettingsHiveModel.fromEntity(settings);
    await _dataSource.put(model);
    return model.toEntity();
  }

  @override
  Future<AppSettingsEntity> reset() async {
    final model = AppSettingsHiveModel.defaults();
    await _dataSource.put(model);
    return model.toEntity();
  }

  @override
  Future<void> clearAllData() async {
    await Future.wait([
      Hive.box<NoteHiveModel>(HiveBoxes.notes).clear(),
      Hive.box<NoteHiveModel>(HiveBoxes.trash).clear(),
      Hive.box<SpaceHiveModel>(HiveBoxes.spaces).clear(),
      Hive.box<TagHiveModel>(HiveBoxes.tags).clear(),
      Hive.box<SearchIndexHiveModel>(HiveBoxes.searchIndex).clear(),
      _dataSource.clear(),
    ]);
    await reset();
  }
}
