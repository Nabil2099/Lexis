import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/app_sync.dart';
import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../../notes/domain/entities/note_entity.dart';

final vaultControllerProvider =
    AsyncNotifierProvider<VaultController, VaultState>(VaultController.new);

class VaultState {
  const VaultState({
    required this.pinned,
    required this.recent,
    required this.activeCount,
  });

  final List<NoteEntity> pinned;
  final List<NoteEntity> recent;
  final int activeCount;
}

class VaultController extends AsyncNotifier<VaultState> {
  @override
  Future<VaultState> build() async {
    ref.watch(appSyncSignalProvider);
    final repo = ref.watch(notesRepositoryProvider);
    final active = await repo.getActive();
    return VaultState(
      pinned: await repo.getPinned(),
      recent: await repo.getRecent(limit: 12),
      activeCount: active.length,
    );
  }

  Future<void> refresh() async => ref.invalidateSelf();
}
