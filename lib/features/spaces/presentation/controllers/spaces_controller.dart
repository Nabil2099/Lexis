import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/app_sync.dart';
import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../data/repositories/spaces_repository_impl.dart';
import '../../domain/entities/space_entity.dart';

final spacesControllerProvider =
    AsyncNotifierProvider<SpacesController, List<SpaceEntity>>(
        SpacesController.new);

class SpacesController extends AsyncNotifier<List<SpaceEntity>> {
  @override
  Future<List<SpaceEntity>> build() async {
    ref.watch(appSyncSignalProvider);
    return ref.watch(spacesRepositoryProvider).getAll();
  }

  Future<SpaceEntity> create(String name, {String? description}) async {
    final space = await ref
        .read(spacesRepositoryProvider)
        .create(name, description: description);
    ref.invalidateSelf();
    notifyAppDataChanged(ref);
    return space;
  }

  Future<void> rename(String id, String name) async {
    final repo = ref.read(spacesRepositoryProvider);
    final space = await repo.getById(id);
    if (space == null) return;
    await repo.update(space.copyWith(name: name));
    ref.invalidateSelf();
    notifyAppDataChanged(ref);
  }

  Future<void> delete(String id) async {
    await ref.read(spacesRepositoryProvider).delete(id);
    ref.invalidateSelf();
    notifyAppDataChanged(ref);
  }
}

final spaceNotesProvider =
    FutureProvider.family.autoDispose((ref, String spaceId) async {
  ref.watch(appSyncSignalProvider);
  final repo = ref.watch(notesRepositoryProvider);
  return repo.bySpace(spaceId);
});
