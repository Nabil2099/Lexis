import 'package:flutter_test/flutter_test.dart';
import 'package:lexis/features/ai_assist/application/note_smart_assist_service.dart';
import 'package:lexis/features/notes/domain/entities/note_entity.dart';
import 'package:lexis/features/settings/domain/entities/app_settings_entity.dart';
import 'package:lexis/features/tags/domain/entities/tag_entity.dart';

void main() {
  const service = NoteSmartAssistService();

  test('generates title from the first markdown heading', () {
    final result = service.suggest(
      note: _note(title: '', content: '# Project Ledger\nTrack invoices.'),
      availableTags: const [],
      settings: AppSettingsEntity.defaults(),
    );

    expect(result.generatedTitle, 'Project Ledger');
  });

  test('generates title from first meaningful sentence when no heading exists',
      () {
    final result = service.suggest(
      note: _note(
        title: 'Untitled',
        content: 'Capture the launch checklist before the team meeting.',
      ),
      availableTags: const [],
      settings: AppSettingsEntity.defaults(),
    );

    expect(
      result.generatedTitle,
      'Capture the launch checklist before the team meeting.',
    );
  });

  test('does not overwrite an existing user title', () {
    final result = service.suggest(
      note: _note(title: 'My title', content: '# Better title\nBody'),
      availableTags: const [],
      settings: AppSettingsEntity.defaults(),
    );

    expect(result.generatedTitle, isNull);
  });

  test('generates concise summaries for short and long content', () {
    final short = service.suggest(
      note: _note(title: 'Short', content: 'A small private note.'),
      availableTags: const [],
      settings: AppSettingsEntity.defaults(),
    );
    final long = service.suggest(
      note: _note(
        title: 'Long',
        content:
            'Lexis should feel calm and private. It should help capture ideas quickly. '
            'The interface should stay focused while still making organization easy.',
      ),
      availableTags: const [],
      settings: AppSettingsEntity.defaults(),
    );

    expect(short.generatedSummary, 'A small private note.');
    expect(long.generatedSummary, hasLength(lessThanOrEqualTo(180)));
    expect(long.generatedSummary, startsWith('Lexis should feel calm'));
  });

  test('suggests matching existing tags without inventing new tags', () {
    final result = service.suggest(
      note: _note(
        title: 'Launch plan',
        content: 'Plan marketing tasks and product launch references.',
      ),
      availableTags: [
        _tag('tag-1', 'Marketing'),
        _tag('tag-2', 'Travel'),
        _tag('tag-3', 'Product Launch'),
      ],
      settings: AppSettingsEntity.defaults(),
    );

    expect(result.suggestedTagIds, containsAll(['tag-1', 'tag-3']));
    expect(result.suggestedTagIds, isNot(contains('Travel')));
  });

  test('does not suggest tags that are already applied', () {
    final result = service.suggest(
      note: _note(
        title: 'Marketing',
        content: 'Marketing notes',
        tagIds: const ['tag-1'],
      ),
      availableTags: [_tag('tag-1', 'Marketing')],
      settings: AppSettingsEntity.defaults(),
    );

    expect(result.suggestedTagIds, isEmpty);
  });
}

NoteEntity _note({
  required String title,
  required String content,
  List<String> tagIds = const [],
}) {
  final now = DateTime(2026);
  return NoteEntity(
    id: 'note-1',
    title: title,
    content: content,
    plainText: content.replaceAll(RegExp(r'[#*`]+'), '').trim(),
    createdAt: now,
    updatedAt: now,
    isPinned: false,
    isArchived: false,
    isDeleted: false,
    tagIds: tagIds,
    type: NoteType.note,
    status: NoteStatus.active,
    wordCount: content.split(RegExp(r'\s+')).length,
    backlinks: const [],
    attachments: const [],
    colorIndex: 0,
  );
}

TagEntity _tag(String id, String name) {
  final now = DateTime(2026);
  return TagEntity(
    id: id,
    name: name,
    colorHex: '#0E7490',
    createdAt: now,
    updatedAt: now,
  );
}
