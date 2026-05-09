import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../../features/notes/data/note_model.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.tags = const [],
    this.showSwipeActions = true,
    this.onPin,
    this.onArchive,
    this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final List<Map<String, dynamic>> tags;
  final bool showSwipeActions;
  final VoidCallback? onPin;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final preview = note.plainPreview;
    final dateStr = _formatDate(note.updatedAt);
    final theme = Theme.of(context);

    final cardContent = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.isPinned) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.push_pin, size: 14, color: AppColors.pinned),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dateStr,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.hint,
                ),
              ),
            ],
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              preview,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.map((tag) {
                final color = _hexToColor(tag['colorHex'] as String);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.4), width: 0.8),
                  ),
                  child: Text(
                    tag['name'] as String,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );

    final cardWithTap = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: cardContent,
      ),
    );

    if (!showSwipeActions) {
      return cardWithTap;
    }

    // Add swipe actions
    return Dismissible(
      key: Key('note-${note.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - pin/unpin
          onPin?.call();
          return false;
        } else {
          // Swipe left - archive
          onArchive?.call();
          return false;
        }
      },
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: AppColors.accent,
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.archive,
          color: AppColors.warning,
        ),
      ),
      child: cardWithTap,
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.accent;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return DateFormat('HH:mm').format(date);
    }
    if (noteDate.year == now.year) {
      return DateFormat('MMM d').format(date);
    }
    return DateFormat('MMM d, y').format(date);
  }
}
