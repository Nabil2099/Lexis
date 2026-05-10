import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../../notes/domain/repositories/notes_repository.dart';
import '../../domain/entities/tag_entity.dart';
import '../../domain/repositories/tags_repository.dart';
import '../datasources/tags_local_datasource.dart';
import '../models/tag_hive_model.dart';

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  return TagsRepositoryImpl(
      TagsLocalDataSource(), ref.watch(notesRepositoryProvider));
});

class TagsRepositoryImpl implements TagsRepository {
  TagsRepositoryImpl(this._dataSource, this._notesRepository);

  final TagsLocalDataSource _dataSource;
  final NotesRepository _notesRepository;

  @override
  Future<List<TagEntity>> getAll() async {
    final tags = <TagEntity>[];
    for (final model in _dataSource.all()) {
      tags.add(model.toEntity(noteCount: await getNoteCount(model.id)));
    }
    tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return tags;
  }

  @override
  Future<TagEntity?> getById(String id) async {
    final model = _dataSource.get(id);
    if (model == null) return null;
    return model.toEntity(noteCount: await getNoteCount(id));
  }

  @override
  Future<TagEntity> create(String name, String colorHex) async {
    final now = DateTime.now();
    final model = TagHiveModel(
      id: const Uuid().v4(),
      name: name.trim(),
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );
    await _dataSource.put(model);
    return model.toEntity();
  }

  @override
  Future<TagEntity> update(TagEntity tag) async {
    final model =
        TagHiveModel.fromEntity(tag.copyWith(updatedAt: DateTime.now()));
    await _dataSource.put(model);
    return model.toEntity(noteCount: await getNoteCount(model.id));
  }

  @override
  Future<void> delete(String id) async {
    final notes = await _notesRepository.byTag(id);
    for (final note in notes) {
      final nextTags = note.tagIds.where((tagId) => tagId != id).toList();
      await _notesRepository
          .update(note.copyWith(tagIds: nextTags, updatedAt: DateTime.now()));
    }
    await _dataSource.delete(id);
  }

  @override
  Future<int> getNoteCount(String tagId) async =>
      (await _notesRepository.byTag(tagId)).length;
}
