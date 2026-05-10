import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../notes/domain/entities/note_entity.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../notes/presentation/widgets/note_type_selector.dart';

class QuickCaptureCard extends ConsumerStatefulWidget {
  const QuickCaptureCard({super.key});

  @override
  ConsumerState<QuickCaptureCard> createState() => _QuickCaptureCardState();
}

class _QuickCaptureCardState extends ConsumerState<QuickCaptureCard> {
  final _controller = TextEditingController();
  NoteType _type = NoteType.note;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      context.push(AppRoutes.newNote);
      return;
    }
    final note = await ref.read(notesControllerProvider.notifier).create(
          title: value.length > 48 ? '${value.substring(0, 48)}...' : value,
          content: value,
          type: _type,
        );
    if (!mounted) return;
    _controller.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Captured in Lexis')));
    context.push('/note/${note.id}');
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Capture a thought...',
              prefixIcon:
                  Icon(Icons.bolt_outlined, color: AppColors.cyanAccent),
            ),
            onSubmitted: (_) => _capture(),
          ),
          const SizedBox(height: 12),
          NoteTypeSelector(
              selected: _type,
              onSelected: (type) => setState(() => _type = type)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _capture,
              icon: const Icon(Icons.add),
              label: const Text('Capture'),
            ),
          ),
        ],
      ),
    );
  }
}
