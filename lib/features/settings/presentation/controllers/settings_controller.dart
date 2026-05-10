import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/app_sync.dart';
import '../../../archive/presentation/controllers/archive_controller.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../search/presentation/controllers/search_controller.dart';
import '../../../spaces/presentation/controllers/spaces_controller.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../../trash/presentation/controllers/trash_controller.dart';
import '../../../vault/presentation/controllers/vault_controller.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings_entity.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettingsEntity>(
        SettingsController.new);

class SettingsController extends AsyncNotifier<AppSettingsEntity> {
  @override
  Future<AppSettingsEntity> build() async =>
      ref.watch(settingsRepositoryProvider).get();

  Future<void> applySettings(AppSettingsEntity settings) async {
    state =
        AsyncData(await ref.read(settingsRepositoryProvider).update(settings));
  }

  Future<void> clearAllData() async {
    await ref.read(settingsRepositoryProvider).clearAllData();
    notifyAppDataChanged(ref);
    ref.invalidate(vaultControllerProvider);
    ref.invalidate(notesControllerProvider);
    ref.invalidate(searchControllerProvider);
    ref.invalidate(spacesControllerProvider);
    ref.invalidate(tagsControllerProvider);
    ref.invalidate(archiveControllerProvider);
    ref.invalidate(trashControllerProvider);
    ref.invalidateSelf();
  }
}
