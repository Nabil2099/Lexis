import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_boxes.dart';
import '../models/space_hive_model.dart';

class SpacesLocalDataSource {
  SpacesLocalDataSource({Box<SpaceHiveModel>? box})
      : _box = box ?? Hive.box<SpaceHiveModel>(HiveBoxes.spaces);

  final Box<SpaceHiveModel> _box;

  List<SpaceHiveModel> all() => _box.values.toList();
  SpaceHiveModel? get(String id) => _box.get(id);
  Future<void> put(SpaceHiveModel model) => _box.put(model.id, model);
  Future<void> delete(String id) => _box.delete(id);
}
