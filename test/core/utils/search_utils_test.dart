import 'package:flutter_test/flutter_test.dart';
import 'package:lexis/core/utils/search_utils.dart';
import 'package:lexis/features/notes/domain/entities/note_entity.dart';
import 'package:lexis/features/search/domain/entities/search_filter_entity.dart';

void main() {
  test('rankAndFilter prefers title matches and respects filters', () {
    final now = DateTime.now();
    final notes = [
      _note('1', 'Random', 'lexis vault', now, NoteType.note,
          tagIds: const ['a']),
      _note('2', 'Lexis Vault', 'private',
          now.subtract(const Duration(days: 1)), NoteType.idea,
          tagIds: const ['b']),
      _note('3', 'Lexis Task', 'done', now, NoteType.task, isDeleted: true),
    ];

    final all = SearchUtils.rankAndFilter(
        notes, const SearchFilterEntity(query: 'lexis'));
    expect(all.map((note) => note.id), ['2', '1']);

    final ideas = SearchUtils.rankAndFilter(
      notes,
      const SearchFilterEntity(query: 'lexis', type: NoteType.idea),
    );
    expect(ideas.single.id, '2');
  });
}

NoteEntity _note(
  String id,
  String title,
  String plainText,
  DateTime updatedAt,
  NoteType type, {
  List<String> tagIds = const [],
  bool isDeleted = false,
}) {
  return NoteEntity(
    id: id,
    title: title,
    content: plainText,
    plainText: plainText,
    createdAt: updatedAt,
    updatedAt: updatedAt,
    isPinned: false,
    isArchived: false,
    isDeleted: isDeleted,
    tagIds: tagIds,
    type: type,
    status: isDeleted ? NoteStatus.deleted : NoteStatus.active,
    wordCount: plainText.split(' ').length,
    backlinks: const [],
    attachments: const [],
    colorIndex: 0,
  );
}
