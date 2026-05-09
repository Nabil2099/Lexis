import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/note_card.dart';
import '../../../notes/data/note_model.dart';
import '../../../notes/presentation/notifiers/notes_notifier.dart';
import '../../../notes/presentation/screens/note_options_sheet.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(archivedNotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: notesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.archive_outlined, size: 64, color: AppColors.hint),
                  const SizedBox(height: 16),
                  const Text(
                    'No archived notes',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Notes you archive will appear here',
                    style: TextStyle(color: AppColors.hint, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () => context.push('/note/${note.id}', extra: note),
                onLongPress: () => _showOptions(context, ref, note),
              );
            },
          );
        },
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, Note note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NoteOptionsSheet(
        note: note,
        onPin: () async {
          Navigator.pop(context);
          await ref
              .read(archivedNotesProvider.notifier)
              .togglePin(note.id);
        },
        onArchive: () async {
          Navigator.pop(context);
          await ref
              .read(archivedNotesProvider.notifier)
              .toggleArchive(note.id);
        },
        onDelete: () async {
          Navigator.pop(context);
          await ref
              .read(archivedNotesProvider.notifier)
              .deleteNote(note.id);
        },
        onEdit: () {
          Navigator.pop(context);
          context.push('/note/${note.id}', extra: note);
        },
      ),
    );
  }
}
