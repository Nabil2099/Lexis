import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../notes/domain/entities/note_entity.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../spaces/presentation/controllers/spaces_controller.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../domain/entities/search_filter_entity.dart';
import '../controllers/search_controller.dart' as lexis_search;

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(lexis_search.searchControllerProvider);
    final spaces = ref.watch(spacesControllerProvider).asData?.value ?? [];
    final tags = ref.watch(tagsControllerProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: search.when(
        loading: () => const AppLoadingState(),
        error: (error, _) => AppErrorState(
            error: error,
            onRetry: () =>
                ref.invalidate(lexis_search.searchControllerProvider)),
        data: (state) {
          if (_controller.text != state.filter.query) {
            _controller.text = state.filter.query;
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              AppSearchField(
                controller: _controller,
                hintText: 'Search notes, ideas, tags...',
                autofocus: true,
                onChanged: (value) =>
                    _update(state.filter.copyWith(query: value)),
              ),
              const SizedBox(height: 14),
              _Filters(
                filter: state.filter,
                spaces: spaces,
                tags: tags,
                onChanged: _update,
              ),
              const SizedBox(height: 22),
              AppSectionHeader(
                title: 'Results',
                subtitle:
                    '${state.results.length} item${state.results.length == 1 ? '' : 's'} found',
              ),
              const SizedBox(height: 12),
              if (state.results.isEmpty)
                AppEmptyState(
                  icon: state.filter.query.trim().isEmpty
                      ? Icons.search
                      : Icons.search_off,
                  title: state.filter.query.trim().isEmpty
                      ? 'Search Lexis'
                      : 'No matching items',
                  message: state.filter.query.trim().isEmpty
                      ? 'Search notes, ideas, references, tags, and spaces from one focused place.'
                      : 'Try a different keyword or filter.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = state.results[index];
                    return NoteCard(
                        note: note,
                        onTap: () => context.push('/note/${note.id}'));
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  void _update(SearchFilterEntity filter) {
    ref
        .read(lexis_search.searchControllerProvider.notifier)
        .updateFilter(filter);
    setState(() {});
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.filter,
    required this.spaces,
    required this.tags,
    required this.onChanged,
  });

  final SearchFilterEntity filter;
  final List<dynamic> spaces;
  final List<dynamic> tags;
  final ValueChanged<SearchFilterEntity> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Pinned'),
                selected: filter.pinnedOnly,
                onSelected: (value) =>
                    onChanged(filter.copyWith(pinnedOnly: value)),
              ),
              const SizedBox(width: 8),
              for (final type in NoteType.values) ...[
                ChoiceChip(
                  label: Text(type.label),
                  selected: filter.type == type,
                  onSelected: (value) =>
                      onChanged(filter.copyWith(type: value ? type : null)),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: filter.spaceId,
                decoration: const InputDecoration(
                  labelText: 'Space',
                  prefixIcon: Icon(Icons.workspaces_outline),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('Any space')),
                  ...spaces.map((space) => DropdownMenuItem<String?>(
                      value: space.id as String, child: Text(space.name))),
                ],
                onChanged: (value) =>
                    onChanged(filter.copyWith(spaceId: value)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: filter.tagId,
                decoration: const InputDecoration(
                  labelText: 'Tag',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('Any tag')),
                  ...tags.map((tag) => DropdownMenuItem<String?>(
                      value: tag.id as String, child: Text(tag.name))),
                ],
                onChanged: (value) => onChanged(filter.copyWith(tagId: value)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
