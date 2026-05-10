import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/app_sync.dart';
import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../../notes/domain/entities/note_entity.dart';

final trashControllerProvider =
    AsyncNotifierProvider<TrashController, List<NoteEntity>>(
        TrashController.new);

class TrashController extends AsyncNotifier<List<NoteEntity>> {
  @override
  Future<List<NoteEntity>> build() async {
    ref.watch(appSyncSignalProvider);
    return ref.watch(notesRepositoryProvider).getDeleted();
  }

  Future<void> restore(String id) async {
    await ref.read(notesRepositoryProvider).restore(id);
    notifyAppDataChanged(ref);
    ref.invalidateSelf();
  }

  Future<void> permanentlyDelete(String id) async {
    await ref.read(notesRepositoryProvider).permanentlyDelete(id);
    notifyAppDataChanged(ref);
    ref.invalidateSelf();
  }

  Future<void> emptyTrash() async {
    await ref.read(notesRepositoryProvider).emptyTrash();
    notifyAppDataChanged(ref);
    ref.invalidateSelf();
  }
}
