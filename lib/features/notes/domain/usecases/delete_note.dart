import '../entities/note_entity.dart';

class DeleteNote {
  const DeleteNote();

  NoteEntity call(NoteEntity note) {
    return note.copyWith(
      isDeleted: true,
      isArchived: false,
      status: NoteStatus.deleted,
      updatedAt: DateTime.now(),
    );
  }
}
