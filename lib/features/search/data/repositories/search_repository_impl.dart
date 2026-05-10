import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notes/data/repositories/notes_repository_impl.dart';
import '../../../notes/domain/entities/note_entity.dart';
import '../../../notes/domain/repositories/notes_repository.dart';
import '../../domain/entities/search_filter_entity.dart';
import '../../domain/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(ref.watch(notesRepositoryProvider));
});

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._notesRepository);

  final NotesRepository _notesRepository;

  @override
  Future<List<NoteEntity>> search(SearchFilterEntity filter) =>
      _notesRepository.search(filter);
}
