import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_section_header.dart';
import '../../../notes/domain/entities/note_entity.dart';
import '../../../notes/presentation/widgets/note_card.dart';

class PinnedNotesSection extends StatelessWidget {
  const PinnedNotesSection({
    super.key,
    required this.notes,
    required this.onOpen,
    required this.onLongPress,
  });

  final List<NoteEntity> notes;
  final ValueChanged<NoteEntity> onOpen;
  final ValueChanged<NoteEntity> onLongPress;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
            title: 'Pinned', subtitle: 'Keep important items close'),
        const SizedBox(height: 12),
        SizedBox(
          height: 166,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final note = notes[index];
              return SizedBox(
                width: 286,
                child: NoteCard(
                  note: note,
                  compact: true,
                  onTap: () => onOpen(note),
                  onLongPress: () => onLongPress(note),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
