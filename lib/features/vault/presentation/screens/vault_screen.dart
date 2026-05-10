import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../notes/domain/entities/note_entity.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../notes/presentation/widgets/note_actions_sheet.dart';
import '../../../daily_notes/application/daily_notes_service.dart';
import '../../../spaces/presentation/controllers/spaces_controller.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../controllers/vault_controller.dart';
import '../widgets/pinned_notes_section.dart';
import '../widgets/quick_capture_card.dart';
import '../widgets/recent_notes_section.dart';
import '../widgets/vault_header.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  _VaultFilter _filter = _VaultFilter.all;

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(vaultControllerProvider);
    final allNotes = ref.watch(notesControllerProvider).asData?.value ?? [];
    final spaceCount =
        ref.watch(spacesControllerProvider).asData?.value.length ?? 0;
    final tagCount =
        ref.watch(tagsControllerProvider).asData?.value.length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: vault.when(
          loading: () => const AppLoadingState(),
          error: (error, _) => AppErrorState(
              error: error,
              onRetry: () => ref.invalidate(vaultControllerProvider)),
          data: (state) {
            final filteredAll = _filterNotes(allNotes);
            final recent = _filter == _VaultFilter.all
                ? state.recent
                : _filterNotes(state.recent);
            final pinned = _filter == _VaultFilter.all
                ? state.pinned
                : _filterNotes(state.pinned);
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(vaultControllerProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  VaultHeader(
                    noteCount: state.activeCount,
                    spaceCount: spaceCount,
                    tagCount: tagCount,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.search),
                    child: const AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search notes, ideas, tags...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const QuickCaptureCard(),
                  const SizedBox(height: 12),
                  _DailyNoteCard(
                    onTap: () => context.push(
                      AppRoutes.daily(
                        DailyNotesService.dateKey(DateTime.now()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SmartFilters(
                    selected: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 24),
                  PinnedNotesSection(
                      notes: pinned,
                      onOpen: _openNote,
                      onLongPress: _showActions),
                  if (pinned.isNotEmpty) const SizedBox(height: 24),
                  RecentNotesSection(
                    notes: recent,
                    title: _filter == _VaultFilter.all
                        ? 'Recently Updated'
                        : 'Filtered Results',
                    onOpen: _openNote,
                    onLongPress: _showActions,
                    onCreate: () => context.push(AppRoutes.newNote),
                  ),
                  if (filteredAll.isNotEmpty &&
                      _filter != _VaultFilter.recent) ...[
                    const SizedBox(height: 24),
                    RecentNotesSection(
                      notes: filteredAll,
                      title: 'All Notes',
                      emptyTitle: 'No notes yet',
                      emptyMessage:
                          'Capture your first thought and build your vault.',
                      onOpen: _openNote,
                      onLongPress: _showActions,
                      onCreate: () => context.push(AppRoutes.newNote),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.newNote),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openNote(NoteEntity note) => context.push('/note/${note.id}');

  List<NoteEntity> _filterNotes(List<NoteEntity> notes) {
    return switch (_filter) {
      _VaultFilter.all => notes,
      _VaultFilter.notes =>
        notes.where((note) => note.type == NoteType.note).toList(),
      _VaultFilter.ideas =>
        notes.where((note) => note.type == NoteType.idea).toList(),
      _VaultFilter.tasks =>
        notes.where((note) => note.type == NoteType.task).toList(),
      _VaultFilter.pinned => notes.where((note) => note.isPinned).toList(),
      _VaultFilter.recent => notes,
    };
  }

  void _showActions(NoteEntity note) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => NoteActionsSheet(
        note: note,
        onEdit: () {
          Navigator.pop(context);
          _openNote(note);
        },
        onPin: () async {
          Navigator.pop(context);
          await ref.read(notesControllerProvider.notifier).togglePin(note.id);
        },
        onArchive: () async {
          Navigator.pop(context);
          await ref.read(notesControllerProvider.notifier).archive(note.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Moved to archive')));
        },
        onDelete: () async {
          Navigator.pop(context);
          final confirmed = await showAppConfirmDialog(
            context,
            title: 'Move to trash?',
            message: 'This item can be restored from Trash later.',
            confirmLabel: 'Move',
            destructive: true,
          );
          if (!confirmed) return;
          await ref.read(notesControllerProvider.notifier).softDelete(note.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Moved to trash')));
        },
      ),
    );
  }
}

class _DailyNoteCard extends StatelessWidget {
  const _DailyNoteCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.today_outlined, color: AppColors.cyanAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Open today',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      'Create or continue your daily note.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

enum _VaultFilter {
  all('All'),
  notes('Notes'),
  ideas('Ideas'),
  tasks('Tasks'),
  pinned('Pinned'),
  recent('Recent');

  const _VaultFilter(this.label);
  final String label;
}

class _SmartFilters extends StatelessWidget {
  const _SmartFilters({
    required this.selected,
    required this.onChanged,
  });

  final _VaultFilter selected;
  final ValueChanged<_VaultFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _VaultFilter.values) ...[
            AppChip(
              label: filter.label,
              selected: selected == filter,
              color: filter == _VaultFilter.pinned
                  ? AppColors.warning
                  : AppColors.primary,
              onTap: () => onChanged(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
