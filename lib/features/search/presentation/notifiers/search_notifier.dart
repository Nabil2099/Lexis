import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../notes/data/notes_repository.dart';
import '../../../notes/data/note_model.dart';

part 'search_notifier.g.dart';

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  Future<List<Note>> build() async {
    return [];
  }

  Future<void> clear() async {
    state = const AsyncData([]);
  }

  Future<List<Note>> search(String query, {int? folderId, int? tagId}) async {
    if (query.isEmpty && folderId == null && tagId == null) {
      state = const AsyncData([]);
      return [];
    }

    final repo = ref.read(notesRepositoryProvider);
    final results =
        await repo.searchNotes(query, folderId: folderId, tagId: tagId).first;
    
    // Load tags for each note
    final notes = <Note>[];
    for (final d in results) {
      final tagIds = await repo.getTagIdsForNote(d.id);
      notes.add(Note.fromDrift(d, tagIds: tagIds));
    }
    state = AsyncData(notes);
    return notes;
  }
}
