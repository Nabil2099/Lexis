import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../../notes/domain/entities/note_entity.dart';

final trashControllerProvider =
    AsyncNotifierProvider<TrashController, List<NoteEntity>>(
        TrashController.new);

class TrashController extends AsyncNotifier<List<NoteEntity>> {
  @override
  Future<List<NoteEntity>> build() async =>
      ref.watch(notesRepositoryProvider).getDeleted();

  Future<void> restore(String id) async {
    await ref.read(notesRepositoryProvider).restore(id);
    ref.invalidateSelf();
  }

  Future<void> permanentlyDelete(String id) async {
    await ref.read(notesRepositoryProvider).permanentlyDelete(id);
    ref.invalidateSelf();
  }

  Future<void> emptyTrash() async {
    await ref.read(notesRepositoryProvider).emptyTrash();
    ref.invalidateSelf();
  }
}
