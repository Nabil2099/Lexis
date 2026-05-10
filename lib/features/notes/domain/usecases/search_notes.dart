import '../../../../core/utils/search_utils.dart';
import '../../../search/domain/entities/search_filter_entity.dart';
import '../entities/note_entity.dart';

class SearchNotes {
  const SearchNotes();

  List<NoteEntity> call(List<NoteEntity> notes, SearchFilterEntity filter) {
    return SearchUtils.rankAndFilter(notes, filter);
  }
}
