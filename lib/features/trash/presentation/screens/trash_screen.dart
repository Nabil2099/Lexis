import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../controllers/trash_controller.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trash = ref.watch(trashControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          trash.maybeWhen(
            data: (notes) => notes.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => _emptyTrash(context, ref),
                    child: const Text('Empty',
                        style: TextStyle(color: AppColors.danger)),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: trash.when(
        loading: () => const AppLoadingState(),
        error: (error, _) => AppErrorState(
            error: error,
            onRetry: () => ref.invalidate(trashControllerProvider)),
        data: (notes) {
          if (notes.isEmpty) {
            return const AppEmptyState(
              icon: Icons.delete_sweep_outlined,
              title: 'Trash is empty',
              message:
                  'Deleted items stay private here until you permanently remove them.',
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
              leading: const Icon(Icons.restore_outlined),
              title: const Text('Restore'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref
                    .read(trashControllerProvider.notifier)
                    .restore(noteId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined,
                  color: AppColors.danger),
              title: const Text('Delete forever',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showAppConfirmDialog(
                  context,
                  title: 'Delete forever?',
                  message: 'This cannot be undone.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (confirmed) {
                  await ref
                      .read(trashControllerProvider.notifier)
                      .permanentlyDelete(noteId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _emptyTrash(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Empty trash?',
      message: 'All trashed items will be permanently deleted.',
      confirmLabel: 'Empty',
      destructive: true,
    );
    if (confirmed) {
      await ref.read(trashControllerProvider.notifier).emptyTrash();
    }
  }
}
