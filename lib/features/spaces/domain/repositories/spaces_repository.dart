import '../entities/space_entity.dart';

abstract class SpacesRepository {
  Future<List<SpaceEntity>> getAll();
  Future<SpaceEntity?> getById(String id);
  Future<SpaceEntity> create(String name, {String? description});
  Future<SpaceEntity> update(SpaceEntity space);
  Future<void> archive(String id);
  Future<void> delete(String id);
  Future<int> getNoteCount(String spaceId);
}
