import 'package:flutter_test/flutter_test.dart';
import 'package:lexis/features/notes/data/models/note_hive_model.dart';
import 'package:lexis/features/notes/domain/entities/note_entity.dart';

void main() {
  test('copyWith regenerates plain text and word count', () {
    final now = DateTime(2026);
    final model = NoteHiveModel(
      id: 'note-1',
      title: 'Original',
      content: 'Hello',
      plainText: 'Hello',
      createdAt: now,
      updatedAt: now,
      isPinned: false,
      isArchived: false,
      isDeleted: false,
      tagIds: const [],
      type: NoteType.note,
      status: NoteStatus.active,
      wordCount: 1,
      backlinks: const [],
      attachments: const [],
      colorIndex: 0,
    );

    final copy = model.copyWith(content: '# Hello **Lexis**');

    expect(copy.plainText, 'Hello Lexis');
    expect(copy.wordCount, 2);
  });

  test('fromEntity and toEntity preserve core fields', () {
    final now = DateTime(2026);
    final entity = NoteEntity(
      id: 'note-2',
      title: 'Idea',
      content: 'Build Lexis',
      plainText: 'Build Lexis',
      createdAt: now,
      updatedAt: now,
      isPinned: true,
      isArchived: false,
      isDeleted: false,
      spaceId: 'space-1',
      folderId: null,
      tagIds: const ['tag-1'],
      type: NoteType.idea,
      status: NoteStatus.active,
      wordCount: 2,
      backlinks: const [],
      attachments: const [],
      summary: null,
      colorIndex: 1,
      dailyDate: '2026-05-10',
    );

    final roundTrip = NoteHiveModel.fromEntity(entity).toEntity();

    expect(roundTrip.id, entity.id);
    expect(roundTrip.type, NoteType.idea);
    expect(roundTrip.isPinned, isTrue);
    expect(roundTrip.tagIds, ['tag-1']);
    expect(roundTrip.dailyDate, '2026-05-10');
  });
}
