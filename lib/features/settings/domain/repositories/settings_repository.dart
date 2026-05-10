import '../entities/app_settings_entity.dart';

abstract class SettingsRepository {
  Future<AppSettingsEntity> get();
  Future<AppSettingsEntity> update(AppSettingsEntity settings);
  Future<AppSettingsEntity> reset();
  Future<void> clearAllData();
}
