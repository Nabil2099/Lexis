import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/search_utils.dart';
import '../../../search/domain/entities/search_filter_entity.dart';
import '../../../sync/data/repositories/sync_queue_repository.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_hive_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl(
    NotesLocalDataSource(),
    ref.watch(syncQueueRepositoryProvider),
  );
});

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._dataSource, this._syncQueue);

  final NotesLocalDataSource _dataSource;
  final SyncQueueRepository _syncQueue;

  @override
  Future<List<NoteEntity>> getAll() async {
    return [..._dataSource.all(), ..._dataSource.trash()]
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<NoteEntity>> getActive() async {
    final notes = _dataSource
        .all()
        .where((note) => !note.isArchived && !note.isDeleted)
        .map((model) => model.toEntity())
        .toList();
    notes.sort(_sortPinnedRecent);
    return notes;
  }

  @override
  Future<List<NoteEntity>> getPinned() async {
    final notes = (await getActive()).where((note) => note.isPinned).toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<List<NoteEntity>> getRecent({int limit = 20}) async {
    final notes = await getActive();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes.take(limit).toList();
  }

  @override
  Future<List<NoteEntity>> getArchived() async {
    final notes = _dataSource
        .all()
        .where((note) => note.isArchived && !note.isDeleted)
        .map((model) => model.toEntity())
        .toList();
    notes.sort(_sortPinnedRecent);
    return notes;
  }

  @override
  Future<List<NoteEntity>> getDeleted() async {
    final notes = _dataSource.trash().map((model) => model.toEntity()).toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<NoteEntity?> getById(String id) async =>
      _dataSource.get(id)?.toEntity();

  @override
  Future<NoteEntity> create(NoteEntity note) async {
    final model = NoteHiveModel.fromEntity(note);
    await _dataSource.put(model);
    await _syncQueue.record(
      entityType: 'note',
      entityId: note.id,
      action: 'create',
    );
    return model.toEntity();
  }

  @override
  Future<NoteEntity> update(NoteEntity note) async {
    final model = NoteHiveModel.fromEntity(note);
    await _dataSource.put(model);
    await _syncQueue.record(
      entityType: 'note',
      entityId: note.id,
      action: 'update',
    );
    return model.toEntity();
  }

  @override
  Future<void> togglePin(String id) async {
    final note = await getById(id);
    if (note == null) return;
    await update(
        note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now()));
  }

  @override
  Future<void> archive(String id) async {
    final note = await getById(id);
    if (note == null) return;
    await update(
      note.copyWith(
        isArchived: true,
        isDeleted: false,
        status: NoteStatus.archived,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> restore(String id) async {
    final note = await getById(id);
    if (note == null) return;
    await update(
      note.copyWith(
        isArchived: false,
        isDeleted: false,
        status: NoteStatus.active,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final note = await getById(id);
    if (note == null) return;
    await update(
      note.copyWith(
        isDeleted: true,
        isArchived: false,
        status: NoteStatus.deleted,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> permanentlyDelete(String id) async {
    await _dataSource.deleteForever(id);
    await _syncQueue.record(entityType: 'note', entityId: id, action: 'delete');
  }

  @override
  Future<void> emptyTrash() => _dataSource.emptyTrash();

  @override
  Future<List<NoteEntity>> search(SearchFilterEntity filter) async {
    return SearchUtils.rankAndFilter(await getAll(), filter);
  }

  @override
  Future<List<NoteEntity>> bySpace(String spaceId) async {
    return (await getActive())
        .where((note) => note.spaceId == spaceId)
        .toList();
  }

  @override
  Future<List<NoteEntity>> byTag(String tagId) async {
    return (await getActive())
        .where((note) => note.tagIds.contains(tagId))
        .toList();
  }

  @override
  Future<List<NoteEntity>> byType(NoteType type) async {
    return (await getActive()).where((note) => note.type == type).toList();
  }

  int _sortPinnedRecent(NoteEntity a, NoteEntity b) {
    final pin = (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0);
    if (pin != 0) return pin;
    return b.updatedAt.compareTo(a.updatedAt);
  }
}
