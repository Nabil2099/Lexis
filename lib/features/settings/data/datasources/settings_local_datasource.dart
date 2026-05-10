import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_boxes.dart';
import '../models/app_settings_hive_model.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource({Box<AppSettingsHiveModel>? box})
      : _box = box ?? Hive.box<AppSettingsHiveModel>(HiveBoxes.settings);

  static const _settingsKey = 'app_settings';
  final Box<AppSettingsHiveModel> _box;

  AppSettingsHiveModel get() {
    final current = _box.get(_settingsKey);
    if (current != null) return current;
    final defaults = AppSettingsHiveModel.defaults();
    _box.put(_settingsKey, defaults);
    return defaults;
  }

  Future<void> put(AppSettingsHiveModel model) => _box.put(_settingsKey, model);
  Future<void> clear() => _box.clear();
}
