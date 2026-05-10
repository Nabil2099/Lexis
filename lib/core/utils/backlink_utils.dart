import '../../features/notes/domain/entities/note_entity.dart';

class BacklinkUtils {
  const BacklinkUtils._();

  static final _wikiLinkPattern = RegExp(r'\[\[([^\]\n]+)\]\]');

  static List<String> extractTitles(String content) {
    final titles = <String>{};
    for (final match in _wikiLinkPattern.allMatches(content)) {
      final title = match.group(1)?.trim();
      if (title != null && title.isNotEmpty) titles.add(title);
    }
    return titles.toList();
  }

  static List<String> resolveLinkedNoteIds({
    required NoteEntity source,
    required List<NoteEntity> notes,
  }) {
    final titleLookup = <String, String>{};
    for (final note in notes) {
      final title = note.title.trim().toLowerCase();
      if (title.isNotEmpty && note.id != source.id) {
        titleLookup[title] = note.id;
      }
    }

    final ids = <String>{};
    for (final title in extractTitles(source.content)) {
      final id = titleLookup[title.toLowerCase()];
      if (id != null) ids.add(id);
    }
    return ids.toList();
  }
}
