import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/note_card.dart';
import '../notifiers/search_notifier.dart';

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
    final resultsAsync = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.primary, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(color: AppColors.hint),
            border: InputBorder.none,
          ),
          onChanged: (query) {
            if (query.trim().isEmpty) {
              ref.read(searchProvider.notifier).clear();
            } else {
              ref.read(searchProvider.notifier).search(query.trim());
            }
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _controller.clear();
                ref.read(searchProvider.notifier).clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: resultsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
        data: (notes) {
          if (_controller.text.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search, size: 64, color: AppColors.hint),
                  const SizedBox(height: 16),
                  const Text(
                    'Search Lexis',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find notes by title or content',
                    style: TextStyle(color: AppColors.hint, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 64, color: AppColors.hint),
                  const SizedBox(height: 16),
                  Text(
                    'No results for "${_controller.text}"',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () => context.push('/note/${note.id}', extra: note),
              );
            },
          );
        },
      ),
    );
  }
}
