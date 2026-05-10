import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_chip.dart';
import '../../domain/entities/note_entity.dart';

class NoteTypeSelector extends StatelessWidget {
  const NoteTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NoteType selected;
  final ValueChanged<NoteType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in NoteType.values) ...[
            AppChip(
              label: type.label,
              selected: selected == type,
              onTap: () => onSelected(type),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
