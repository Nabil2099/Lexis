import '../../../search/domain/entities/search_filter_entity.dart';
import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getAll();
  Future<List<NoteEntity>> getActive();
  Future<List<NoteEntity>> getPinned();
  Future<List<NoteEntity>> getRecent({int limit = 20});
  Future<List<NoteEntity>> getArchived();
  Future<List<NoteEntity>> getDeleted();
  Future<NoteEntity?> getById(String id);
  Future<NoteEntity> create(NoteEntity note);
  Future<NoteEntity> update(NoteEntity note);
  Future<void> togglePin(String id);
  Future<void> archive(String id);
  Future<void> restore(String id);
  Future<void> softDelete(String id);
  Future<void> permanentlyDelete(String id);
  Future<void> emptyTrash();
  Future<List<NoteEntity>> search(SearchFilterEntity filter);
  Future<List<NoteEntity>> bySpace(String spaceId);
  Future<List<NoteEntity>> byTag(String tagId);
  Future<List<NoteEntity>> byType(NoteType type);
}
