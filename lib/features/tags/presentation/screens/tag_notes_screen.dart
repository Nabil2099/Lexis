import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../controllers/tags_controller.dart';

class TagNotesScreen extends ConsumerWidget {
  const TagNotesScreen({
    super.key,
    required this.tagId,
    required this.tagName,
  });

  final String tagId;
  final String tagName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(tagNotesProvider(tagId));
    return Scaffold(
      appBar: AppBar(title: Text('#$tagName')),
      body: notes.when(
        loading: () => const AppLoadingState(),
        error: (error, _) => AppErrorState(error: error),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.sell_outlined,
              title: 'No tagged items',
              message: 'Assign this tag from the editor to connect notes here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = items[index];
              return NoteCard(
                  note: note, onTap: () => context.push('/note/${note.id}'));
            },
          );
        },
      ),
    );
  }
}
