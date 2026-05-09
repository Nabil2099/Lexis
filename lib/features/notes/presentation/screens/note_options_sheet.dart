import 'package:flutter/material.dart';
import '../../data/note_model.dart';
import '../../../../core/theme/app_colors.dart';

class NoteOptionsSheet extends StatelessWidget {
  const NoteOptionsSheet({
    super.key,
    required this.note,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
    required this.onEdit,
  });

  final Note note;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Edit'),
              onTap: onEdit,
            ),
            ListTile(
              leading: Icon(
                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: AppColors.pinned,
              ),
              title: Text(note.isPinned ? 'Unpin' : 'Pin'),
              onTap: onPin,
            ),
            ListTile(
              leading: Icon(
                note.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                color: AppColors.secondary,
              ),
              title: Text(note.isArchived ? 'Unarchive' : 'Archive'),
              onTap: onArchive,
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: const Text(
                'Delete',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surfaceHigh,
                    title: const Text('Delete note?'),
                    content: const Text(
                      'This action cannot be undone.',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
