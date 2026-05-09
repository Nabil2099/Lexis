import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/note_card.dart';
import '../../../notes/data/note_model.dart';
import '../../../notes/presentation/notifiers/notes_notifier.dart';
import '../../../notes/presentation/screens/note_options_sheet.dart';

class FolderNotesScreen extends ConsumerWidget {
  const FolderNotesScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  final int folderId;
  final String folderName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = folderNotesProvider(FolderNotesParam(folderId));
    final notesAsync = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(folderName)),
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
                  const Icon(Icons.note_outlined, size: 64, color: AppColors.hint),
                  const SizedBox(height: 16),
                  const Text(
                    'No notes in this folder',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/note/new', extra: folderId),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Note'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note/new', extra: folderId),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, Note note) {
    final provider = folderNotesProvider(FolderNotesParam(folderId));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => NoteOptionsSheet(
        note: note,
        onPin: () async {
          Navigator.pop(context);
          await ref.read(provider.notifier).togglePin(note.id);
        },
        onArchive: () async {
          Navigator.pop(context);
          await ref.read(provider.notifier).toggleArchive(note.id);
        },
        onDelete: () async {
          Navigator.pop(context);
          await ref.read(provider.notifier).deleteNote(note.id);
        },
        onEdit: () {
          Navigator.pop(context);
          context.push('/note/${note.id}', extra: note);
        },
      ),
    );
  }
}
