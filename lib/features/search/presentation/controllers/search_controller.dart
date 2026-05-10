import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notes/domain/entities/note_entity.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/search_filter_entity.dart';

final searchControllerProvider =
    AsyncNotifierProvider<SearchController, SearchState>(SearchController.new);

class SearchState {
  const SearchState({
    required this.filter,
    required this.results,
  });

  final SearchFilterEntity filter;
  final List<NoteEntity> results;

  SearchState copyWith({
    SearchFilterEntity? filter,
    List<NoteEntity>? results,
  }) {
    return SearchState(
      filter: filter ?? this.filter,
      results: results ?? this.results,
    );
  }
}

class SearchController extends AsyncNotifier<SearchState> {
  @override
  Future<SearchState> build() async {
    const filter = SearchFilterEntity();
    return SearchState(
        filter: filter,
        results: await ref.watch(searchRepositoryProvider).search(filter));
  }

  Future<void> updateFilter(SearchFilterEntity filter) async {
    final results = await ref.read(searchRepositoryProvider).search(filter);
    state = AsyncData(SearchState(filter: filter, results: results));
  }

  Future<void> clear() => updateFilter(const SearchFilterEntity());
}
