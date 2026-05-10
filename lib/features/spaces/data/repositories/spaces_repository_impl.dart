import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../../notes/domain/repositories/notes_repository.dart';
import '../../../sync/data/repositories/sync_queue_repository.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../datasources/spaces_local_datasource.dart';
import '../models/space_hive_model.dart';

final spacesRepositoryProvider = Provider<SpacesRepository>((ref) {
  return SpacesRepositoryImpl(
    SpacesLocalDataSource(),
    ref.watch(notesRepositoryProvider),
    ref.watch(syncQueueRepositoryProvider),
  );
});

class SpacesRepositoryImpl implements SpacesRepository {
  SpacesRepositoryImpl(
      this._dataSource, this._notesRepository, this._syncQueue);

  final SpacesLocalDataSource _dataSource;
  final NotesRepository _notesRepository;
  final SyncQueueRepository _syncQueue;

  @override
  Future<List<SpaceEntity>> getAll() async {
    final spaces = <SpaceEntity>[];
    for (final model in _dataSource.all().where((space) => !space.isArchived)) {
      spaces.add(model.toEntity(noteCount: await getNoteCount(model.id)));
    }
    spaces.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return spaces;
  }

  @override
  Future<SpaceEntity?> getById(String id) async {
    final model = _dataSource.get(id);
    if (model == null) return null;
    return model.toEntity(noteCount: await getNoteCount(id));
  }

  @override
  Future<SpaceEntity> create(String name, {String? description}) async {
    final now = DateTime.now();
    final model = SpaceHiveModel(
      id: const Uuid().v4(),
      name: name.trim(),
      description: description,
      iconCodePoint: 0,
      colorIndex: 0,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
    );
    await _dataSource.put(model);
    await _syncQueue.record(
      entityType: 'space',
      entityId: model.id,
      action: 'create',
    );
    return model.toEntity();
  }

  @override
  Future<SpaceEntity> update(SpaceEntity space) async {
    final model =
        SpaceHiveModel.fromEntity(space.copyWith(updatedAt: DateTime.now()));
    await _dataSource.put(model);
    await _syncQueue.record(
      entityType: 'space',
      entityId: model.id,
      action: 'update',
    );
    return model.toEntity(noteCount: await getNoteCount(model.id));
  }

  @override
  Future<void> archive(String id) async {
    final space = _dataSource.get(id);
    if (space == null) return;
    await _dataSource
        .put(space.copyWith(isArchived: true, updatedAt: DateTime.now()));
    await _syncQueue.record(
        entityType: 'space', entityId: id, action: 'update');
  }

  @override
  Future<void> delete(String id) async {
    final notes = await _notesRepository.bySpace(id);
    for (final note in notes) {
      await _notesRepository
          .update(note.copyWith(spaceId: null, updatedAt: DateTime.now()));
    }
    await _dataSource.delete(id);
    await _syncQueue.record(
        entityType: 'space', entityId: id, action: 'delete');
  }

  @override
  Future<int> getNoteCount(String spaceId) async =>
      (await _notesRepository.bySpace(spaceId)).length;
}
