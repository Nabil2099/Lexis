import 'package:flutter_test/flutter_test.dart';
import 'package:lexis/features/settings/data/models/app_settings_hive_model.dart';
import 'package:lexis/features/settings/domain/entities/app_settings_entity.dart';

void main() {
  test('defaults enable offline Smart Assist features', () {
    final settings = AppSettingsEntity.defaults();

    expect(settings.smartAssistEnabled, isTrue);
    expect(settings.smartAssistAutoTitle, isTrue);
    expect(settings.smartAssistAutoSummary, isTrue);
    expect(settings.smartAssistSuggestTags, isTrue);
    expect(settings.encryptionKeyReady, isFalse);
    expect(settings.appLockEnabled, isFalse);
    expect(settings.syncEnabled, isFalse);
  });

  test('Hive settings round trip preserves Smart Assist settings', () {
    final entity = AppSettingsEntity.defaults().copyWith(
      smartAssistEnabled: false,
      smartAssistAutoTitle: false,
      smartAssistAutoSummary: true,
      smartAssistSuggestTags: false,
      encryptionKeyReady: true,
      appLockEnabled: true,
      syncEnabled: true,
    );

    final roundTrip = AppSettingsHiveModel.fromEntity(entity).toEntity();

    expect(roundTrip.smartAssistEnabled, isFalse);
    expect(roundTrip.smartAssistAutoTitle, isFalse);
    expect(roundTrip.smartAssistAutoSummary, isTrue);
    expect(roundTrip.smartAssistSuggestTags, isFalse);
    expect(roundTrip.encryptionKeyReady, isTrue);
    expect(roundTrip.appLockEnabled, isTrue);
    expect(roundTrip.syncEnabled, isTrue);
  });
}
