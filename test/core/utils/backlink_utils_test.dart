import 'package:flutter_test/flutter_test.dart';
import 'package:lexis/core/utils/backlink_utils.dart';
import 'package:lexis/features/notes/domain/entities/note_entity.dart';

void main() {
  test('extractTitles parses wiki-style links', () {
    expect(
      BacklinkUtils.extractTitles('Link [[Project Alpha]] and [[ Daily ]]'),
      ['Project Alpha', 'Daily'],
    );
  });

  test('resolveLinkedNoteIds maps linked titles to note ids', () {
    final source = _note(
      id: 'source',
      title: 'Source',
      content: 'See [[Target Note]] and [[Missing]].',
    );
    final target = _note(id: 'target', title: 'Target Note', content: '');

    expect(
      BacklinkUtils.resolveLinkedNoteIds(source: source, notes: [
        source,
        target,
      ]),
      ['target'],
    );
  });
}

NoteEntity _note({
  required String id,
  required String title,
  required String content,
}) {
  final now = DateTime(2026);
  return NoteEntity(
    id: id,
    title: title,
    content: content,
    plainText: content,
    createdAt: now,
    updatedAt: now,
    isPinned: false,
    isArchived: false,
    isDeleted: false,
    tagIds: const [],
    type: NoteType.note,
    status: NoteStatus.active,
    wordCount: 0,
    backlinks: const [],
    attachments: const [],
    colorIndex: 0,
  );
}
