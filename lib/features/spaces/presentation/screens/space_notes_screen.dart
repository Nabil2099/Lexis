import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../controllers/spaces_controller.dart';

class SpaceNotesScreen extends ConsumerWidget {
  const SpaceNotesScreen({
    super.key,
    required this.spaceId,
    required this.spaceName,
  });

  final String spaceId;
  final String spaceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(spaceNotesProvider(spaceId));
    return Scaffold(
      appBar: AppBar(title: Text(spaceName)),
      body: notes.when(
        loading: () => const AppLoadingState(),
        error: (error, _) => AppErrorState(error: error),
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              icon: Icons.note_add_outlined,
              title: 'Nothing here yet',
              message:
                  'Create an item and assign it to this space from the editor.',
              action: FilledButton.icon(
                onPressed: () => context.push('/note/new'),
                icon: const Icon(Icons.add),
                label: const Text('Create item'),
              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
