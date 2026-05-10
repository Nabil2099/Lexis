import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../data/repositories/tags_repository_impl.dart';
import '../../domain/entities/tag_entity.dart';

final tagsControllerProvider =
    AsyncNotifierProvider<TagsController, List<TagEntity>>(TagsController.new);

class TagsController extends AsyncNotifier<List<TagEntity>> {
  @override
  Future<List<TagEntity>> build() async =>
      ref.watch(tagsRepositoryProvider).getAll();

  Future<TagEntity> create(String name, {String? colorHex}) async {
    final tag = await ref.read(tagsRepositoryProvider).create(
          name,
          colorHex ??
              _hex(AppColors.tagColors[(state.asData?.value.length ?? 0)
                  .remainder(AppColors.tagColors.length)]),
        );
    ref.invalidateSelf();
    return tag;
  }

  Future<void> saveTag(TagEntity tag) async {
    await ref.read(tagsRepositoryProvider).update(tag);
    ref.invalidateSelf();
  }

  Future<void> rename(String id, String name) async {
    final repo = ref.read(tagsRepositoryProvider);
    final tag = await repo.getById(id);
    if (tag == null) return;
    await repo.update(tag.copyWith(name: name));
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(tagsRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

final tagNotesProvider =
    FutureProvider.family.autoDispose((ref, String tagId) async {
  final repo = ref.watch(notesRepositoryProvider);
  return repo.byTag(tagId);
});
