import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/local_storage/hive_boxes.dart';
import '../../../../core/sync/app_sync.dart';
import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../../sync/data/repositories/sync_queue_repository.dart';
import '../../domain/entities/attachment_entity.dart';
import '../models/attachment_hive_model.dart';

final attachmentsRepositoryProvider = Provider<AttachmentsRepository>((ref) {
  return AttachmentsRepository(ref);
});

final noteAttachmentsProvider =
    FutureProvider.family.autoDispose<List<AttachmentEntity>, String>(
  (ref, noteId) async {
    ref.watch(appSyncSignalProvider);
    return ref.watch(attachmentsRepositoryProvider).forNote(noteId);
  },
);

class AttachmentsRepository {
  AttachmentsRepository(this._ref)
      : _box = Hive.box<AttachmentHiveModel>(HiveBoxes.attachments);

  final Ref _ref;
  final Box<AttachmentHiveModel> _box;

  List<AttachmentEntity> forNote(String noteId) {
    return _box.values
        .where((attachment) => attachment.noteId == noteId)
        .map((model) => model.toEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<AttachmentEntity?> pickAndAttach(String noteId) async {
    final result = await FilePicker.pickFiles(withData: true);
    final file = result?.files.single;
    if (file == null) return null;

    final attachment = AttachmentHiveModel(
      id: const Uuid().v4(),
      noteId: noteId,
      fileName: file.name,
      localPath: file.path ?? '',
      mimeType: 'application/octet-stream',
      sizeBytes: file.size,
      createdAt: DateTime.now(),
    );
    await _box.put(attachment.id, attachment);

    final notes = _ref.read(notesRepositoryProvider);
    final note = await notes.getById(noteId);
    if (note != null) {
      await notes.update(
        note.copyWith(
          attachments: {...note.attachments, attachment.id}.toList(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    await _ref.read(syncQueueRepositoryProvider).record(
          entityType: 'attachment',
          entityId: attachment.id,
          action: 'create',
        );
    notifyAppDataChanged(_ref);
    return attachment.toEntity();
  }

  Future<void> remove(String attachmentId) async {
    final attachment = _box.get(attachmentId);
    if (attachment == null) return;
    await _box.delete(attachmentId);
    final notes = _ref.read(notesRepositoryProvider);
    final note = await notes.getById(attachment.noteId);
    if (note != null) {
      await notes.update(
        note.copyWith(
          attachments:
              note.attachments.where((id) => id != attachmentId).toList(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    await _ref.read(syncQueueRepositoryProvider).record(
          entityType: 'attachment',
          entityId: attachmentId,
          action: 'delete',
        );
    notifyAppDataChanged(_ref);
  }
}
