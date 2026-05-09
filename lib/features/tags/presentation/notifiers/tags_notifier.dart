import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/tags_repository.dart';
import '../../data/tag_model.dart';

part 'tags_notifier.g.dart';

@riverpod
class TagsNotifier extends _$TagsNotifier {
  @override
  Future<List<Tag>> build() async {
    final repo = ref.watch(tagsRepositoryProvider);
    final tagsStream = repo.watchAllTags();

    return tagsStream.first
        .then((data) => data.map((d) => Tag.fromDrift(d)).toList());
  }

  Future<int> createTag(String name, [String colorHex = '#6C63FF']) async {
    final repo = ref.read(tagsRepositoryProvider);
    final id = await repo.createTag(name, colorHex);
    ref.invalidateSelf();
    return id;
  }

  Future<void> renameTag(int id, String name) async {
    final repo = ref.read(tagsRepositoryProvider);
    await repo.updateTag(id, name: name);
    ref.invalidateSelf();
  }

  Future<void> updateTag(int id, {String? name, String? colorHex}) async {
    final repo = ref.read(tagsRepositoryProvider);
    await repo.updateTag(id, name: name, colorHex: colorHex);
    ref.invalidateSelf();
  }

  Future<void> deleteTag(int id) async {
    if (!ref.mounted) return;
    final repo = ref.read(tagsRepositoryProvider);
    await repo.deleteTag(id);
    ref.invalidateSelf();
  }
}
