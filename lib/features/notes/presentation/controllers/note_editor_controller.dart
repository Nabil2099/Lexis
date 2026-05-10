import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../archive/presentation/controllers/archive_controller.dart';
import '../../../search/presentation/controllers/search_controller.dart';
import '../../../spaces/presentation/controllers/spaces_controller.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../../trash/presentation/controllers/trash_controller.dart';
import '../../../vault/presentation/controllers/vault_controller.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/update_note.dart';
import 'notes_controller.dart';

final noteEditorControllerProvider =
    AsyncNotifierProvider.family<NoteEditorController, NoteEntity?, String?>(
  NoteEditorController.new,
);

class NoteEditorController extends AsyncNotifier<NoteEntity?> {
  NoteEditorController(this.noteId);

  final String? noteId;

  @override
  Future<NoteEntity?> build() async {
    if (noteId == null) return null;
    return ref.watch(notesRepositoryProvider).getById(noteId!);
  }

  Future<NoteEntity> save({
    required String title,
    required String content,
    required NoteType type,
    required String? spaceId,
    required List<String> tagIds,
  }) async {
    final repo = ref.read(notesRepositoryProvider);
    final current = state.asData?.value;
    final saved = current == null
        ? await repo.create(
            const CreateNote()(
              title: title,
              content: content,
              type: type,
              spaceId: spaceId,
              tagIds: tagIds,
            ),
          )
        : await repo.update(
            const UpdateNote()(
              current,
              title: title,
              content: content,
              type: type,
              spaceId: spaceId,
              tagIds: tagIds,
            ),
          );
    state = AsyncData(saved);
    _refreshDependents();
    return saved;
  }

  Future<void> togglePin() async {
    final note = state.asData?.value;
    if (note == null) return;
    await ref.read(notesRepositoryProvider).togglePin(note.id);
    state = AsyncData(await ref.read(notesRepositoryProvider).getById(note.id));
    _refreshDependents();
  }

  Future<void> archive() async {
    final note = state.asData?.value;
    if (note == null) return;
    await ref.read(notesRepositoryProvider).archive(note.id);
    state = AsyncData(await ref.read(notesRepositoryProvider).getById(note.id));
    _refreshDependents();
  }

  void _refreshDependents() {
    ref.invalidate(vaultControllerProvider);
    ref.invalidate(notesControllerProvider);
    ref.invalidate(archiveControllerProvider);
    ref.invalidate(trashControllerProvider);
    ref.invalidate(spacesControllerProvider);
    ref.invalidate(tagsControllerProvider);
    ref.invalidate(searchControllerProvider);
  }
}
