import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/note_card.dart';
import '../../data/note_model.dart';
import '../notifiers/notes_notifier.dart';
import 'note_options_sheet.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lexis',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              size: 22,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 22),
            color: AppColors.surfaceHigh,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
              const PopupMenuItem(value: 'tags', child: Text('Manage Tags')),
            ],
            onSelected: (value) {
              if (value == 'archive') context.go(AppRoutes.archive);
              if (value == 'tags') context.go(AppRoutes.tags);
            },
          ),
        ],
      ),
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
          return RefreshIndicator(
            onRefresh: () => ref.read(notesProvider.notifier).refresh(),
            child: notes.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.note_outlined,
                                size: 64, color: AppColors.hint),
                            SizedBox(height: 16),
                            Text(
                              'No notes yet',
                              style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap + to create your first note',
                              style: TextStyle(
                                  color: AppColors.hint, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : _isGridView
                    ? _buildGridView(notes)
                    : _buildListView(notes),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/note/new'),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildListView(List<Note> notes) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final note = notes[index];
        final tags = note.tagIds.map((tagId) {
          return {'id': tagId, 'name': 'Tag $tagId', 'colorHex': '#5E8EFF'};
        }).toList();
        
        return Hero(
          tag: 'note-${note.id}',
          child: NoteCard(
            note: note,
            tags: tags,
            onTap: () => context.push('/note/${note.id}', extra: note),
            onLongPress: () => _showOptions(context, ref, note),
            onPin: () => ref.read(notesProvider.notifier).togglePin(note.id),
            onArchive: () => ref.read(notesProvider.notifier).toggleArchive(note.id),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final tags = note.tagIds.map((tagId) {
          return {'id': tagId, 'name': 'Tag $tagId', 'colorHex': '#5E8EFF'};
        }).toList();
        
        return Hero(
          tag: 'note-${note.id}',
          child: NoteCard(
            note: note,
            tags: tags,
            onTap: () => context.push('/note/${note.id}', extra: note),
            onLongPress: () => _showOptions(context, ref, note),
            showSwipeActions: false, // Disable swipe in grid to avoid conflicts
          ),
        );
      },
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
          await ref.read(notesProvider.notifier).togglePin(note.id);
        },
        onArchive: () async {
          Navigator.pop(context);
          await ref.read(notesProvider.notifier).toggleArchive(note.id);
        },
        onDelete: () async {
          Navigator.pop(context);
          await ref.read(notesProvider.notifier).deleteNote(note.id);
        },
        onEdit: () {
          Navigator.pop(context);
          context.push('/note/${note.id}', extra: note);
        },
      ),
    );
  }
}
