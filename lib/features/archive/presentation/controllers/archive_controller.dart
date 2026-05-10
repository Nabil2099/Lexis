import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../../notes/domain/entities/note_entity.dart';

final archiveControllerProvider =
    AsyncNotifierProvider<ArchiveController, List<NoteEntity>>(
        ArchiveController.new);

class ArchiveController extends AsyncNotifier<List<NoteEntity>> {
  @override
  Future<List<NoteEntity>> build() async =>
      ref.watch(notesRepositoryProvider).getArchived();

  Future<void> restore(String id) async {
    await ref.read(notesRepositoryProvider).restore(id);
    ref.invalidateSelf();
  }

  Future<void> moveToTrash(String id) async {
    await ref.read(notesRepositoryProvider).softDelete(id);
    ref.invalidateSelf();
  }
}
