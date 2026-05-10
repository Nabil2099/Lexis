import '../entities/tag_entity.dart';

abstract class TagsRepository {
  Future<List<TagEntity>> getAll();
  Future<TagEntity?> getById(String id);
  Future<TagEntity> create(String name, String colorHex);
  Future<TagEntity> update(TagEntity tag);
  Future<void> delete(String id);
  Future<int> getNoteCount(String tagId);
}
