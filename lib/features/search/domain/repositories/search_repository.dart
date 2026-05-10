import '../../../notes/domain/entities/note_entity.dart';
import '../entities/search_filter_entity.dart';

abstract class SearchRepository {
  Future<List<NoteEntity>> search(SearchFilterEntity filter);
}
