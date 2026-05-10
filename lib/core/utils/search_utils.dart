import '../../features/notes/domain/entities/note_entity.dart';
import '../../features/search/domain/entities/search_filter_entity.dart';

class SearchUtils {
  const SearchUtils._();

  static String normalize(String value) => value.toLowerCase().trim();

  static List<NoteEntity> rankAndFilter(
      List<NoteEntity> notes, SearchFilterEntity filter) {
    final query = normalize(filter.query);
    final filtered = notes.where((note) {
      if (!filter.includeDeleted && note.isDeleted) {
        return false;
      }
      if (!filter.includeArchived && note.isArchived) {
        return false;
      }
      if (filter.type != null && note.type != filter.type) {
        return false;
      }
      if (filter.tagId != null && !note.tagIds.contains(filter.tagId)) {
        return false;
      }
      if (filter.spaceId != null && note.spaceId != filter.spaceId) {
        return false;
      }
      if (filter.pinnedOnly && !note.isPinned) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return normalize(note.title).contains(query) ||
          normalize(note.plainText).contains(query);
    }).toList();

    filtered.sort((a, b) {
      final score = _score(b, query).compareTo(_score(a, query));
      if (score != 0) {
        return score;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return filtered;
  }

  static int _score(NoteEntity note, String query) {
    var score = 0;
    final title = normalize(note.title);
    final content = normalize(note.plainText);
    if (query.isNotEmpty && title.contains(query)) {
      score += title == query ? 80 : 60;
    }
    if (query.isNotEmpty && content.contains(query)) {
      score += 25;
    }
    if (note.isPinned) {
      score += 10;
    }
    final ageHours = DateTime.now().difference(note.updatedAt).inHours;
    score += (168 - ageHours).clamp(0, 168);
    return score;
  }
}
