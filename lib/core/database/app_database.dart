import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ─────────────────────────── Tables ──────────────────────────────

class NotesTable extends Table {
  @override
  String get tableName => 'notes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get folderId => integer().nullable()();
}

class FoldersTable extends Table {
  @override
  String get tableName => 'folders';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class TagsTable extends Table {
  @override
  String get tableName => 'tags';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get colorHex => text()();
}

// Many-to-many join table: note <> tags
class NoteTagsTable extends Table {
  @override
  String get tableName => 'note_tags';

  IntColumn get noteId => integer().references(NotesTable, #id)();
  IntColumn get tagId => integer().references(TagsTable, #id)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

// ─────────────────────────── Database ──────────────────────────────

@DriftDatabase(tables: [NotesTable, FoldersTable, TagsTable, NoteTagsTable])
class AppDatabase extends _$AppDatabase {
  static QueryExecutor openConnection() {
    // driftDatabase automatically uses WASM for web and FFI for native
    return driftDatabase(name: 'lexis_db');
  }

  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;
}
