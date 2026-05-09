import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

part 'tags_repository.g.dart';

@Riverpod(keepAlive: true)
TagsRepository tagsRepository(Ref ref) {
  return TagsRepository(ref.watch(appDatabaseProvider));
}

class TagsRepository {
  final AppDatabase _db;

  TagsRepository(this._db);

  // Watch all tags
  Stream<List<TagsTableData>> watchAllTags() {
    final query = _db.select(_db.tagsTable)
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    return query.watch();
  }

  // Get a single tag by ID
  Future<TagsTableData?> getTagById(int id) async {
    final query = _db.select(_db.tagsTable)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  // Get a single tag by name
  Future<TagsTableData?> getTagByName(String name) async {
    final query = _db.select(_db.tagsTable)..where((t) => t.name.equals(name));
    return query.getSingleOrNull();
  }

  // Create a new tag
  Future<int> createTag(String name, String colorHex) async {
    final id = await _db.into(_db.tagsTable).insert(
          TagsTableCompanion.insert(name: name, colorHex: colorHex),
        );
    return id;
  }

  // Update tag
  Future<void> updateTag(int id, {String? name, String? colorHex}) async {
    await (_db.update(_db.tagsTable)..where((t) => t.id.equals(id))).write(
      TagsTableCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        colorHex: colorHex != null ? Value(colorHex) : const Value.absent(),
      ),
    );
  }

  // Delete a tag (removes from all notes)
  Future<void> deleteTag(int id) async {
    // First, remove tag from all notes
    await (_db.delete(_db.noteTagsTable)..where((t) => t.tagId.equals(id)))
        .go();
    // Then delete the tag
    await (_db.delete(_db.tagsTable)..where((t) => t.id.equals(id))).go();
  }

  // Get note count for a tag
  Future<int> getNoteCount(int tagId) async {
    final query = _db.select(_db.noteTagsTable)
      ..where((t) => t.tagId.equals(tagId));
    final rows = await query.get();
    return rows.length;
  }

  // Watch note count for a tag
  Stream<int> watchNoteCount(int tagId) {
    final query = _db.select(_db.noteTagsTable)
      ..where((t) => t.tagId.equals(tagId));
    return query.watch().map((rows) => rows.length);
  }
}
