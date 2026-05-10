import '../entities/note_entity.dart';

class ArchiveNote {
  const ArchiveNote();

  NoteEntity call(NoteEntity note) {
    return note.copyWith(
      isArchived: true,
      isDeleted: false,
      status: NoteStatus.archived,
      updatedAt: DateTime.now(),
    );
  }
}
