import 'package:uuid/uuid.dart';

import '../../../../core/utils/markdown_utils.dart';
import '../entities/note_entity.dart';

class CreateNote {
  const CreateNote();

  NoteEntity call({
    String title = '',
    String content = '',
    NoteType type = NoteType.note,
    String? spaceId,
    List<String> tagIds = const [],
    String? dailyDate,
  }) {
    final now = DateTime.now();
    return NoteEntity(
      id: const Uuid().v4(),
      title: title,
      content: content,
      plainText: MarkdownUtils.toPlainText(content),
      createdAt: now,
      updatedAt: now,
      isPinned: false,
      isArchived: false,
      isDeleted: false,
      spaceId: spaceId,
      folderId: null,
      tagIds: tagIds,
      type: type,
      status: title.trim().isEmpty && content.trim().isEmpty
          ? NoteStatus.draft
          : NoteStatus.active,
      wordCount: MarkdownUtils.wordCount(content),
      backlinks: const [],
      attachments: const [],
      summary: null,
      colorIndex: 0,
      dailyDate: dailyDate,
    );
  }
}
