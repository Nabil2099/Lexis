import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../domain/entities/note_entity.dart';

class NoteActionsSheet extends StatelessWidget {
  const NoteActionsSheet({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  final NoteEntity note;
  final VoidCallback onEdit;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: note.displayTitle,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Edit'),
          onTap: onEdit,
        ),
        ListTile(
          leading: Icon(
            note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: AppColors.warning,
          ),
          title: Text(note.isPinned ? 'Unpin' : 'Pin'),
          onTap: onPin,
        ),
        ListTile(
          leading: Icon(
            note.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
          ),
          title: Text(note.isArchived ? 'Restore from archive' : 'Archive'),
          onTap: onArchive,
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: AppColors.danger),
          title: const Text(
            'Move to trash',
            style: TextStyle(color: AppColors.danger),
          ),
          onTap: onDelete,
        ),
      ],
    );
  }
}
