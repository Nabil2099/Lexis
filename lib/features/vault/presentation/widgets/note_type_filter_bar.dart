import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_chip.dart';
import '../../../notes/domain/entities/note_entity.dart';

class NoteTypeFilterBar extends StatelessWidget {
  const NoteTypeFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final NoteType? selected;
  final ValueChanged<NoteType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppChip(
              label: 'All',
              selected: selected == null,
              onTap: () => onChanged(null)),
          const SizedBox(width: 8),
          for (final type in NoteType.values) ...[
            AppChip(
                label: type.label,
                selected: selected == type,
                onTap: () => onChanged(type)),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
