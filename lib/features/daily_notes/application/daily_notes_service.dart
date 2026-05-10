import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/data/repositories/notes_repository_impl.dart';
import '../../notes/domain/entities/note_entity.dart';
import '../../notes/domain/usecases/create_note.dart';
import '../../sync/data/repositories/sync_queue_repository.dart';

final dailyNotesServiceProvider = Provider<DailyNotesService>((ref) {
  return DailyNotesService(ref);
});

class DailyNotesService {
  DailyNotesService(this._ref);

  final Ref _ref;

  Future<NoteEntity> getOrCreate(DateTime date) async {
    final key = dateKey(date);
    final repo = _ref.read(notesRepositoryProvider);
    final existing = (await repo.getAll())
        .where((note) => !note.isDeleted && note.dailyDate == key)
        .firstOrNull;
    if (existing != null) return existing;

    final note = await repo.create(
      const CreateNote()(
        title: 'Daily Note - $key',
        content: '# Daily Note - $key\n\n',
        type: NoteType.journal,
        dailyDate: key,
      ),
    );
    await _ref.read(syncQueueRepositoryProvider).record(
          entityType: 'note',
          entityId: note.id,
          action: 'create',
        );
    return note;
  }

  static String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
