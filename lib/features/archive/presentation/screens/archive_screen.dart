import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../controllers/archive_controller.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archive = ref.watch(archiveControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: archive.when(
        loading: () => const AppLoadingState(),
        error: (error, _) => AppErrorState(
            error: error,
            onRetry: () => ref.invalidate(archiveControllerProvider)),
        data: (notes) {
          if (notes.isEmpty) {
            return const AppEmptyState(
              icon: Icons.archive_outlined,
              title: 'Archive is empty',
              message:
                  'Older items you archive will rest here until you restore or trash them.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () => context.push('/note/${note.id}'),
                onLongPress: () => _showActions(context, ref, note.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, String noteId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.unarchive_outlined),
              title: const Text('Restore'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref
                    .read(notesControllerProvider.notifier)
                    .restore(noteId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Move to trash'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showAppConfirmDialog(
                  context,
                  title: 'Move archived item to trash?',
                  message: 'You can restore it later from Trash.',
                  confirmLabel: 'Move',
                  destructive: true,
                );
                if (confirmed) {
                  await ref
                      .read(notesControllerProvider.notifier)
                      .softDelete(noteId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
