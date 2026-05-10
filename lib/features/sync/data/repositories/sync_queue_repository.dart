import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/local_storage/hive_boxes.dart';
import '../models/sync_record_hive_model.dart';

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository();
});

class SyncQueueRepository {
  SyncQueueRepository({Box<SyncRecordHiveModel>? box})
      : _box = box ?? Hive.box<SyncRecordHiveModel>(HiveBoxes.syncQueue);

  final Box<SyncRecordHiveModel> _box;

  List<SyncRecordHiveModel> all() => _box.values.toList();

  Future<void> record({
    required String entityType,
    required String entityId,
    required String action,
  }) async {
    final now = DateTime.now();
    final record = SyncRecordHiveModel(
      id: const Uuid().v4(),
      entityType: entityType,
      entityId: entityId,
      action: action,
      createdAt: now,
    );
    await _box.put(record.id, record);
  }

  Future<void> clear() => _box.clear();
}
