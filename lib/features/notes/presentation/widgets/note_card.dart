import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.onPin,
    this.onArchive,
    this.compact = false,
  });

  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPin;
  final VoidCallback? onArchive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final preview = note.summary?.trim().isNotEmpty == true
        ? note.summary!.trim()
        : note.plainText;

    return Dismissible(
      key: ValueKey('note-${note.id}'),
      direction: onPin == null && onArchive == null
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) onPin?.call();
        if (direction == DismissDirection.endToStart) onArchive?.call();
        return false;
      },
      background: _SwipeBackground(
          icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
      secondaryBackground:
          const _SwipeBackground(icon: Icons.archive_outlined, alignEnd: true),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: EdgeInsets.all(compact ? 14 : 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: note.isPinned
                    ? AppColors.primary.withValues(alpha: 0.58)
                    : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _TypeBadge(type: note.type),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (note.isPinned)
                      const Icon(Icons.push_pin,
                          size: 15, color: AppColors.warning),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    preview,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.55, color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (note.tagIds.isNotEmpty)
                      _MetaPill(
                          label:
                              '${note.tagIds.length} tag${note.tagIds.length == 1 ? '' : 's'}')
                    else
                      _MetaPill(label: note.status.name),
                    const Spacer(),
                    Text(
                      LexisDateUtils.compact(note.updatedAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.icon, this.alignEnd = false});

  final IconData icon;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: AppColors.cyanAccent),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final NoteType type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      NoteType.note => AppColors.primary,
      NoteType.idea => AppColors.warning,
      NoteType.task => AppColors.success,
      NoteType.journal => AppColors.cyanAccent,
      NoteType.reference => AppColors.textSecondary,
      NoteType.codeSnippet => AppColors.textMuted,
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const SizedBox(width: 9, height: 9),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
