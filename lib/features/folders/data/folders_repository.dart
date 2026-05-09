import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

part 'folders_repository.g.dart';

@Riverpod(keepAlive: true)
FoldersRepository foldersRepository(Ref ref) {
  return FoldersRepository(ref.watch(appDatabaseProvider));
}

class FoldersRepository {
  final AppDatabase _db;

  FoldersRepository(this._db);

  // Watch all folders
  Stream<List<FoldersTableData>> watchAllFolders() {
    final query = _db.select(_db.foldersTable)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    return query.watch();
  }

  // Get a single folder by ID
  Future<FoldersTableData?> getFolderById(int id) async {
    final query = _db.select(_db.foldersTable)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  // Create a new folder
  Future<int> createFolder(String name) async {
    final id = await _db.into(_db.foldersTable).insert(
          FoldersTableCompanion.insert(
            name: name,
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  // Update folder name
  Future<void> updateFolderName(int id, String name) async {
    await (_db.update(_db.foldersTable)..where((t) => t.id.equals(id))).write(
      FoldersTableCompanion(name: Value(name)),
    );
  }

  // Delete a folder (notes in folder become unfoldered)
  Future<void> deleteFolder(int id) async {
    // First, unfolder all notes in this folder
    await (_db.update(_db.notesTable)..where((t) => t.folderId.equals(id)))
        .write(const NotesTableCompanion(folderId: Value(null)));
    // Then delete the folder
    await (_db.delete(_db.foldersTable)..where((t) => t.id.equals(id))).go();
  }

  // Get note count for a folder
  Future<int> getNoteCount(int folderId) async {
    final query = _db.select(_db.notesTable)
      ..where((t) => t.folderId.equals(folderId) & t.isArchived.equals(false));
    final notes = await query.get();
    return notes.length;
  }

  // Watch note count for a folder
  Stream<int> watchNoteCount(int folderId) {
    final query = _db.select(_db.notesTable)
      ..where((t) => t.folderId.equals(folderId) & t.isArchived.equals(false));
    return query.watch().map((notes) => notes.length);
  }
}
