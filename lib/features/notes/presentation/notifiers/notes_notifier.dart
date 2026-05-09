import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/notes_repository.dart';
import '../../data/note_model.dart';

part 'notes_notifier.g.dart';

// ---------------------------------------------------------------------------
// All non-archived notes notifier (real-time reactive)
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class NotesNotifier extends _$NotesNotifier {
  @override
  Future<List<Note>> build() async {
    final repo = ref.watch(notesRepositoryProvider);
    final data = await repo.watchAllNotes().first;
    
    // Load tags for each note
    final notes = <Note>[];
    for (final d in data) {
      final tagIds = await repo.getTagIdsForNote(d.id);
      notes.add(Note.fromDrift(d, tagIds: tagIds));
    }
    return notes;
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<int> createNote(
      {String title = '', String content = '', int? folderId}) async {
    final repo = ref.read(notesRepositoryProvider);
    final id = await repo.createNote(
      title: title,
      content: content,
      folderId: folderId,
    );
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateNote(int id, {String? title, String? content}) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.updateNote(id, title: title, content: content);
    ref.invalidateSelf();
  }

  Future<void> togglePin(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.togglePin(id);
    ref.invalidateSelf();
  }

  Future<void> toggleArchive(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.toggleArchive(id);
    ref.invalidateSelf();
  }

  Future<void> moveToFolder(int noteId, int? folderId) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.moveToFolder(noteId, folderId);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.deleteNote(id);
    ref.invalidateSelf();
  }

  Future<void> addTagToNote(int noteId, int tagId) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.addTagToNote(noteId, tagId);
    ref.invalidateSelf();
  }

  Future<void> removeTagFromNote(int noteId, int tagId) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.removeTagFromNote(noteId, tagId);
    ref.invalidateSelf();
  }

  Future<void> setTagsForNote(int noteId, List<int> tagIds) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.setTagsForNote(noteId, tagIds);
    ref.invalidateSelf();
  }
}

// ---------------------------------------------------------------------------
// Archived notes notifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class ArchivedNotesNotifier extends _$ArchivedNotesNotifier {
  @override
  Future<List<Note>> build() async {
    final repo = ref.watch(notesRepositoryProvider);
    final data = await repo.watchArchivedNotes().first;
    
    // Load tags for each note
    final notes = <Note>[];
    for (final d in data) {
      final tagIds = await repo.getTagIdsForNote(d.id);
      notes.add(Note.fromDrift(d, tagIds: tagIds));
    }
    return notes;
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<void> togglePin(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.togglePin(id);
    ref.invalidateSelf();
  }

  Future<void> toggleArchive(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.toggleArchive(id);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.deleteNote(id);
    ref.invalidateSelf();
  }
}

// ---------------------------------------------------------------------------
// Folder notes notifier (per-folder, keyed by folderId)
// ---------------------------------------------------------------------------

class FolderNotesParam {
  final int folderId;
  const FolderNotesParam(this.folderId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderNotesParam &&
          runtimeType == other.runtimeType &&
          folderId == other.folderId;

  @override
  int get hashCode => folderId.hashCode;
}

@riverpod
class FolderNotesNotifier extends _$FolderNotesNotifier {
  late final int _folderId;

  @override
  Future<List<Note>> build(FolderNotesParam param) async {
    _folderId = param.folderId;
    final repo = ref.watch(notesRepositoryProvider);
    final data = await repo.watchNotesByFolder(_folderId).first;
    
    // Load tags for each note
    final notes = <Note>[];
    for (final d in data) {
      final tagIds = await repo.getTagIdsForNote(d.id);
      notes.add(Note.fromDrift(d, tagIds: tagIds));
    }
    return notes;
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<void> togglePin(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.togglePin(id);
    ref.invalidateSelf();
  }

  Future<void> toggleArchive(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.toggleArchive(id);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.deleteNote(id);
    ref.invalidateSelf();
  }
}
