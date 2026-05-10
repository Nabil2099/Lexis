import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_boxes.dart';
import '../models/tag_hive_model.dart';

class TagsLocalDataSource {
  TagsLocalDataSource({Box<TagHiveModel>? box})
      : _box = box ?? Hive.box<TagHiveModel>(HiveBoxes.tags);

  final Box<TagHiveModel> _box;

  List<TagHiveModel> all() => _box.values.toList();
  TagHiveModel? get(String id) => _box.get(id);
  Future<void> put(TagHiveModel model) => _box.put(model.id, model);
  Future<void> delete(String id) => _box.delete(id);
}
