import '../../../../core/utils/markdown_utils.dart';
import '../entities/note_entity.dart';

class UpdateNote {
  const UpdateNote();

  NoteEntity call(
    NoteEntity note, {
    String? title,
    String? content,
    NoteType? type,
    String? spaceId,
    List<String>? tagIds,
    Object? dailyDate = _sentinel,
  }) {
    final nextContent = content ?? note.content;
    return note.copyWith(
      title: title,
      content: nextContent,
      plainText: MarkdownUtils.toPlainText(nextContent),
      updatedAt: DateTime.now(),
      type: type,
      spaceId: spaceId,
      tagIds: tagIds,
      wordCount: MarkdownUtils.wordCount(nextContent),
      dailyDate: dailyDate == _sentinel ? note.dailyDate : dailyDate as String?,
      status: note.isArchived
          ? NoteStatus.archived
          : note.isDeleted
              ? NoteStatus.deleted
              : NoteStatus.active,
    );
  }
}

const Object _sentinel = Object();
