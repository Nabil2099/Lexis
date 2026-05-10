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

final notesControllerProvider =
    AsyncNotifierProvider<NotesController, List<NoteEntity>>(
        NotesController.new);

class NotesController extends AsyncNotifier<List<NoteEntity>> {
  @override
  Future<List<NoteEntity>> build() async =>
      ref.watch(notesRepositoryProvider).getActive();

  Future<NoteEntity> create({
    String title = '',
    String content = '',
    NoteType type = NoteType.note,
    String? spaceId,
    List<String> tagIds = const [],
  }) async {
    final note = const CreateNote()(
      title: title,
      content: content,
      type: type,
      spaceId: spaceId,
      tagIds: tagIds,
    );
    final saved = await ref.read(notesRepositoryProvider).create(note);
    _refreshDependents();
    return saved;
  }

  Future<void> togglePin(String id) async {
    await ref.read(notesRepositoryProvider).togglePin(id);
    _refreshDependents();
  }

  Future<void> archive(String id) async {
    await ref.read(notesRepositoryProvider).archive(id);
    _refreshDependents();
  }

  Future<void> restore(String id) async {
    await ref.read(notesRepositoryProvider).restore(id);
    _refreshDependents();
  }

  Future<void> softDelete(String id) async {
    await ref.read(notesRepositoryProvider).softDelete(id);
    _refreshDependents();
  }

  Future<void> permanentlyDelete(String id) async {
    await ref.read(notesRepositoryProvider).permanentlyDelete(id);
    _refreshDependents();
  }

  void _refreshDependents() {
    ref.invalidateSelf();
    ref.invalidate(vaultControllerProvider);
    ref.invalidate(archiveControllerProvider);
    ref.invalidate(trashControllerProvider);
    ref.invalidate(spacesControllerProvider);
    ref.invalidate(tagsControllerProvider);
    ref.invalidate(searchControllerProvider);
  }
}
