import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/space_entity.dart';
import '../controllers/spaces_controller.dart';

class SpacesScreen extends ConsumerWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = ref.watch(spacesControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spaces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showSpaceDialog(context, ref),
          ),
        ],
      ),
      body: spaces.when(
        loading: () => const AppLoadingState(),
        error: (error, _) => AppErrorState(
            error: error,
            onRetry: () => ref.invalidate(spacesControllerProvider)),
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              icon: Icons.workspaces_outline,
              title: 'No spaces yet',
              message:
                  'Create spaces for projects, research, journals, or areas of focus.',
              action: FilledButton.icon(
                onPressed: () => _showSpaceDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Create space'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final space = items[index];
              return AppCard(
                onTap: () =>
                    context.push('/spaces/${space.id}', extra: space.name),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.18),
                      foregroundColor: AppColors.cyanAccent,
                      child: const Icon(Icons.workspaces_outline),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(space.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 3),
                          Text(
                              '${space.noteCount} item${space.noteCount == 1 ? '' : 's'}'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showSpaceActions(context, ref, space),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSpaceDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSpaceDialog(BuildContext context, WidgetRef ref,
      {SpaceEntity? space}) {
    final controller = TextEditingController(text: space?.name ?? '');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(space == null ? 'New space' : 'Rename space'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Space name'),
          onSubmitted: (_) =>
              _submitSpace(dialogContext, ref, controller.text, space),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () =>
                _submitSpace(dialogContext, ref, controller.text, space),
            child: Text(space == null ? 'Create' : 'Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitSpace(BuildContext context, WidgetRef ref, String name,
      SpaceEntity? space) async {
    final value = name.trim();
    if (value.isEmpty) return;
    if (space == null) {
      await ref.read(spacesControllerProvider.notifier).create(value);
    } else {
      await ref.read(spacesControllerProvider.notifier).rename(space.id, value);
    }
    if (context.mounted) Navigator.pop(context);
  }

  void _showSpaceActions(
      BuildContext context, WidgetRef ref, SpaceEntity space) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showSpaceDialog(context, ref, space: space);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('Delete',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showAppConfirmDialog(
                  context,
                  title: 'Delete space?',
                  message:
                      'Notes inside this space will stay in your vault without a space.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (confirmed) {
                  await ref
                      .read(spacesControllerProvider.notifier)
                      .delete(space.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
