import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/folders_repository.dart';
import '../../data/folder_model.dart';

part 'folders_notifier.g.dart';

@riverpod
class FoldersNotifier extends _$FoldersNotifier {
  @override
  Future<List<Folder>> build() async {
    final repo = ref.watch(foldersRepositoryProvider);
    final data = await repo.watchAllFolders().first;

    // Load note count for each folder
    final folders = <Folder>[];
    for (final d in data) {
      final noteCount = await repo.getNoteCount(d.id);
      folders.add(Folder.fromDrift(d, noteCount: noteCount));
    }
    return folders;
  }

  Future<int> createFolder(String name) async {
    final repo = ref.read(foldersRepositoryProvider);
    final id = await repo.createFolder(name);
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateFolderName(int id, String name) async {
    final repo = ref.read(foldersRepositoryProvider);
    await repo.updateFolderName(id, name);
    ref.invalidateSelf();
  }

  Future<void> renameFolder(int folderId, String name) async {
    final repo = ref.read(foldersRepositoryProvider);
    await repo.updateFolderName(folderId, name);
    ref.invalidateSelf();
  }

  Future<void> deleteFolder(int id) async {
    if (!ref.mounted) return;
    final repo = ref.read(foldersRepositoryProvider);
    await repo.deleteFolder(id);
    ref.invalidateSelf();
  }
}
