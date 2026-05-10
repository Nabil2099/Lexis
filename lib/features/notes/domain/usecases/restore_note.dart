import '../entities/note_entity.dart';

class RestoreNote {
  const RestoreNote();

  NoteEntity call(NoteEntity note) {
    return note.copyWith(
      isArchived: false,
      isDeleted: false,
      status: NoteStatus.active,
      updatedAt: DateTime.now(),
    );
  }
}
