import '../entities/note_entity.dart';

class PinNote {
  const PinNote();

  NoteEntity call(NoteEntity note) =>
      note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now());
}
