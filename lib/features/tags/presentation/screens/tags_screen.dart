import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../domain/entities/tag_entity.dart';
import '../controllers/tags_controller.dart';

class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showTagDialog(context, ref)),
        ],
      ),
      body: tags.when(
        loading: () => const AppLoadingState(),
        error: (error, _) => AppErrorState(
            error: error,
            onRetry: () => ref.invalidate(tagsControllerProvider)),
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              icon: Icons.sell_outlined,
              title: 'No tags yet',
              message: 'Use tags to connect related ideas across spaces.',
              action: FilledButton.icon(
                onPressed: () => _showTagDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Create tag'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final tag = items[index];
              final color = _colorFromHex(tag.colorHex);
              return AppCard(
                onTap: () => context.push('/tags/${tag.id}', extra: tag.name),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tag.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 3),
                          Text(
                              '${tag.noteCount} item${tag.noteCount == 1 ? '' : 's'}'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showTagActions(context, ref, tag),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTagDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTagDialog(BuildContext context, WidgetRef ref, {TagEntity? tag}) {
    final controller = TextEditingController(text: tag?.name ?? '');
    var selectedColor = tag?.colorHex ?? '#0E7490';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tag == null ? 'New tag' : 'Edit tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Tag name'),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  for (final color in AppColors.tagColors)
                    InkWell(
                      onTap: () => setState(() => selectedColor = _hex(color)),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == _hex(color)
                                ? AppColors.textPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                if (tag == null) {
                  await ref
                      .read(tagsControllerProvider.notifier)
                      .create(name, colorHex: selectedColor);
                } else {
                  await ref.read(tagsControllerProvider.notifier).saveTag(
                        tag.copyWith(name: name, colorHex: selectedColor),
                      );
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(tag == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagActions(BuildContext context, WidgetRef ref, TagEntity tag) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showTagDialog(context, ref, tag: tag);
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
                  title: 'Delete tag?',
                  message:
                      'This removes the tag from every item, but does not delete notes.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (confirmed) {
                  await ref
                      .read(tagsControllerProvider.notifier)
                      .delete(tag.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromHex(String hex) {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  }

  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}
