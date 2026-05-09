import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

part 'notes_repository.g.dart';

@Riverpod(keepAlive: true)
NotesRepository notesRepository(Ref ref) {
  return NotesRepository(ref.watch(appDatabaseProvider));
}

class NotesRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  NotesRepository(this._db);

  // Watch all notes (non-archived, sorted by pinned first, then updatedAt desc)
  Stream<List<NotesTableData>> watchAllNotes() {
    final query = _db.select(_db.notesTable)
      ..where((t) => t.isArchived.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  // Watch notes in a specific folder
  Stream<List<NotesTableData>> watchNotesByFolder(int folderId) {
    final query = _db.select(_db.notesTable)
      ..where((t) => t.folderId.equals(folderId) & t.isArchived.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  // Watch archived notes
  Stream<List<NotesTableData>> watchArchivedNotes() {
    final query = _db.select(_db.notesTable)
      ..where((t) => t.isArchived.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  // Watch pinned notes
  Stream<List<NotesTableData>> watchPinnedNotes() {
    final query = _db.select(_db.notesTable)
      ..where((t) => t.isPinned.equals(true) & t.isArchived.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  // Get a single note by ID
  Future<NotesTableData?> getNoteById(int id) async {
    final query = _db.select(_db.notesTable)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  // Create a new note
  Future<int> createNote({String title = '', String content = '', int? folderId}) async {
    final now = DateTime.now();
    final id = await _db.into(_db.notesTable).insert(
          NotesTableCompanion.insert(
            uuid: _uuid.v4(),
            title: Value(title),
            content: Value(content),
            createdAt: now,
            updatedAt: now,
            folderId: Value(folderId),
          ),
        );
    return id;
  }

  // Update a note
  Future<void> updateNote(int id,
      {String? title,
      String? content,
      bool? isPinned,
      bool? isArchived,
      int? folderId}) async {
    await (_db.update(_db.notesTable)..where((t) => t.id.equals(id))).write(
      NotesTableCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        content: content != null ? Value(content) : const Value.absent(),
        isPinned: isPinned != null ? Value(isPinned) : const Value.absent(),
        isArchived:
            isArchived != null ? Value(isArchived) : const Value.absent(),
        folderId: folderId != null ? Value(folderId) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Toggle pin status
  Future<void> togglePin(int id) async {
    final note = await getNoteById(id);
    if (note != null) {
      await updateNote(id, isPinned: !note.isPinned);
    }
  }

  // Toggle archive status
  Future<void> toggleArchive(int id) async {
    final note = await getNoteById(id);
    if (note != null) {
      await updateNote(id, isArchived: !note.isArchived);
    }
  }

  // Move note to folder (null = no folder)
  Future<void> moveToFolder(int noteId, int? folderId) async {
    await updateNote(noteId, folderId: folderId);
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    // First delete any tag associations
    await (_db.delete(_db.noteTagsTable)..where((t) => t.noteId.equals(id)))
        .go();
    // Then delete the note
    await (_db.delete(_db.notesTable)..where((t) => t.id.equals(id))).go();
  }

  // Search notes by title or content
  Stream<List<NotesTableData>> searchNotes(String query,
      {int? folderId, int? tagId}) {
    final pattern = '%$query%';
    
    if (folderId != null && tagId != null) {
      // Complex query with both filters - use join to filter by tag
      final q = _db.select(_db.notesTable).join([
        leftOuterJoin(
          _db.noteTagsTable,
          _db.noteTagsTable.noteId.equalsExp(_db.notesTable.id),
        ),
      ]);
      q.where(_db.notesTable.isArchived.equals(false) &
          (_db.notesTable.title.like(pattern) | _db.notesTable.content.like(pattern)) &
          _db.notesTable.folderId.equals(folderId) &
          (_db.noteTagsTable.tagId.equals(tagId) | _db.noteTagsTable.tagId.isNull()));
      q.orderBy([
        OrderingTerm(expression: _db.notesTable.isPinned, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.notesTable.updatedAt, mode: OrderingMode.desc),
      ]);
      // Deduplicate by note ID
      return q.watch().map((rows) {
        final seen = <int>{};
        return rows
            .map((row) => row.readTable(_db.notesTable))
            .where((note) => seen.add(note.id))
            .toList();
      });
    } else if (folderId != null) {
      final q = _db.select(_db.notesTable);
      q.where((t) =>
          t.isArchived.equals(false) &
          (t.title.like(pattern) | t.content.like(pattern)) &
          t.folderId.equals(folderId));
      q.orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
      return q.watch();
    } else if (tagId != null) {
      // Filter by tagId using join
      final q = _db.select(_db.notesTable).join([
        innerJoin(
          _db.noteTagsTable,
          _db.noteTagsTable.noteId.equalsExp(_db.notesTable.id),
        ),
      ]);
      q.where(_db.notesTable.isArchived.equals(false) &
          (_db.notesTable.title.like(pattern) | _db.notesTable.content.like(pattern)) &
          _db.noteTagsTable.tagId.equals(tagId));
      q.orderBy([
        OrderingTerm(expression: _db.notesTable.isPinned, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.notesTable.updatedAt, mode: OrderingMode.desc),
      ]);
      // Deduplicate by note ID
      return q.watch().map((rows) {
        final seen = <int>{};
        return rows
            .map((row) => row.readTable(_db.notesTable))
            .where((note) => seen.add(note.id))
            .toList();
      });
    } else {
      final q = _db.select(_db.notesTable);
      q.where((t) =>
          t.isArchived.equals(false) &
          (t.title.like(pattern) | t.content.like(pattern)));
      q.orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
      return q.watch();
    }
  }

  // Get tags for a note
  Future<List<TagsTableData>> getTagsForNote(int noteId) async {
    final query = _db.select(_db.noteTagsTable).join([
      innerJoin(
          _db.tagsTable, _db.tagsTable.id.equalsExp(_db.noteTagsTable.tagId)),
    ])
      ..where(_db.noteTagsTable.noteId.equals(noteId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.tagsTable)).toList();
  }

  // Get tag IDs for a note
  Future<List<int>> getTagIdsForNote(int noteId) async {
    final query = _db.select(_db.noteTagsTable)
      ..where((t) => t.noteId.equals(noteId));
    final rows = await query.get();
    return rows.map((row) => row.tagId).toList();
  }

  // Watch tag IDs for a note
  Stream<List<int>> watchTagIdsForNote(int noteId) {
    final query = _db.select(_db.noteTagsTable)
      ..where((t) => t.noteId.equals(noteId));
    return query.watch().map((rows) => rows.map((row) => row.tagId).toList());
  }

  // Add tag to note
  Future<void> addTagToNote(int noteId, int tagId) async {
    await _db.into(_db.noteTagsTable).insertOnConflictUpdate(
          NoteTagsTableCompanion.insert(noteId: noteId, tagId: tagId),
        );
  }

  // Remove tag from note
  Future<void> removeTagFromNote(int noteId, int tagId) async {
    await (_db.delete(_db.noteTagsTable)
          ..where((t) => t.noteId.equals(noteId) & t.tagId.equals(tagId)))
        .go();
  }

  // Set tags for a note (replace all)
  Future<void> setTagsForNote(int noteId, List<int> tagIds) async {
    await (_db.delete(_db.noteTagsTable)..where((t) => t.noteId.equals(noteId)))
        .go();
    for (final tagId in tagIds) {
      await _db.into(_db.noteTagsTable).insert(
            NoteTagsTableCompanion.insert(noteId: noteId, tagId: tagId),
          );
    }
  }
}
