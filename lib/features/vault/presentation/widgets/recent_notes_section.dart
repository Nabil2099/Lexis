import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../notes/domain/entities/note_entity.dart';
import '../../../notes/presentation/widgets/note_card.dart';

class RecentNotesSection extends StatelessWidget {
  const RecentNotesSection({
    super.key,
    required this.notes,
    required this.onOpen,
    required this.onLongPress,
    this.title = 'Recently Updated',
    this.emptyTitle = 'No notes yet',
    this.emptyMessage = 'Capture your first thought and build your vault.',
    this.onCreate,
  });

  final List<NoteEntity> notes;
  final ValueChanged<NoteEntity> onOpen;
  final ValueChanged<NoteEntity> onLongPress;
  final String title;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return AppEmptyState(
        icon: Icons.auto_stories_outlined,
        title: emptyTitle,
        message: emptyMessage,
        action: FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: const Text('Create first item'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title, subtitle: '${notes.length} items'),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              note: note,
              onTap: () => onOpen(note),
              onLongPress: () => onLongPress(note),
            );
          },
        ),
      ],
    );
  }
}
