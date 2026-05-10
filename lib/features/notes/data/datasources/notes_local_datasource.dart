import 'package:hive/hive.dart';

import '../../../../core/local_storage/hive_boxes.dart';
import '../../../search/data/models/search_index_hive_model.dart';
import '../models/note_hive_model.dart';

class NotesLocalDataSource {
  NotesLocalDataSource({
    Box<NoteHiveModel>? notesBox,
    Box<NoteHiveModel>? trashBox,
    Box<SearchIndexHiveModel>? searchBox,
  })  : _notesBox = notesBox ?? Hive.box<NoteHiveModel>(HiveBoxes.notes),
        _trashBox = trashBox ?? Hive.box<NoteHiveModel>(HiveBoxes.trash),
        _searchBox =
            searchBox ?? Hive.box<SearchIndexHiveModel>(HiveBoxes.searchIndex);

  final Box<NoteHiveModel> _notesBox;
  final Box<NoteHiveModel> _trashBox;
  final Box<SearchIndexHiveModel> _searchBox;

  List<NoteHiveModel> all() => _notesBox.values.toList();
  List<NoteHiveModel> trash() => _trashBox.values.toList();
  NoteHiveModel? get(String id) => _notesBox.get(id) ?? _trashBox.get(id);

  Future<void> put(NoteHiveModel model) async {
    if (model.isDeleted) {
      await _notesBox.delete(model.id);
      await _trashBox.put(model.id, model);
    } else {
      await _trashBox.delete(model.id);
      await _notesBox.put(model.id, model);
    }
    await updateIndex(model);
  }

  Future<void> deleteForever(String id) async {
    await _notesBox.delete(id);
    await _trashBox.delete(id);
    await _searchBox.delete(id);
  }

  Future<void> emptyTrash() async {
    for (final id in _trashBox.keys.cast<String>().toList()) {
      await _searchBox.delete(id);
    }
    await _trashBox.clear();
  }

  Future<void> updateIndex(NoteHiveModel model) async {
    if (model.isDeleted) {
      await _searchBox.delete(model.id);
      return;
    }
    await _searchBox.put(
        model.id, SearchIndexHiveModel.fromNote(model.toEntity()));
  }
}
