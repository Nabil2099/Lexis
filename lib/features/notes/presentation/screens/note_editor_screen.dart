import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/markdown_utils.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../ai_assist/domain/entities/note_smart_assist_result.dart';
import '../../../attachments/data/repositories/attachments_repository.dart';
import '../../../attachments/domain/entities/attachment_entity.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../spaces/presentation/controllers/spaces_controller.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../domain/entities/note_entity.dart';
import '../controllers/note_editor_controller.dart';
import '../widgets/markdown_preview.dart';
import '../widgets/note_type_selector.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _initialized = false;
  bool _dirty = false;
  bool _preview = false;
  NoteType _type = NoteType.note;
  String? _spaceId;
  List<String> _tagIds = [];
  NoteSmartAssistResult? _assistResult;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _hydrate(NoteEntity? note) {
    if (_initialized) return;
    final settings = ref.read(settingsControllerProvider).asData?.value;
    _titleController.text = note?.title ?? '';
    _contentController.text = note?.content ?? '';
    _type = note?.type ?? NoteType.note;
    _spaceId = note?.spaceId;
    _tagIds = [...?note?.tagIds];
    _preview = settings?.useMarkdownPreview ?? false;
    _titleController.addListener(() => _dirty = true);
    _contentController.addListener(() => _dirty = true);
    _initialized = true;
  }

  Future<void> _save({bool feedback = false}) async {
    final existing =
        ref.read(noteEditorControllerProvider(widget.noteId)).asData?.value;
    final title = _titleController.text.trim();
    final content = _contentController.text;
    if (existing == null && title.isEmpty && content.trim().isEmpty) return;
    final result = await ref
        .read(noteEditorControllerProvider(widget.noteId).notifier)
        .save(
          title: title,
          content: content,
          type: _type,
          spaceId: _spaceId,
          tagIds: _tagIds,
        );
    if (!mounted) return;
    if (result.generatedTitle != null && _titleController.text.trim().isEmpty) {
      _titleController.text = result.note.title;
    }
    setState(() {
      _assistResult = result.generatedAnything ? result : null;
    });
    _dirty = false;
    if (feedback && mounted) {
      final message = result.generatedAnything
          ? 'Saved with Smart Assist suggestions'
          : 'Saved';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _applySuggestedTags(List<String> tagIds) async {
    final updated = await ref
        .read(noteEditorControllerProvider(widget.noteId).notifier)
        .applySuggestedTags(tagIds);
    if (!mounted || updated == null) return;
    setState(() {
      _tagIds = [...updated.tagIds];
      _assistResult = null;
      _dirty = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Applied ${tagIds.length} suggested tag${tagIds.length == 1 ? '' : 's'}',
        ),
      ),
    );
  }

  Future<void> _regenerateSmartAssist(NoteEntity note) async {
    final hasTitle = note.title.trim().isNotEmpty;
    var replaceTitle = false;
    if (hasTitle) {
      replaceTitle = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Replace title?'),
              content: const Text(
                'Smart Assist can refresh the summary and tags now. Replace the current title too?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep title'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Replace'),
                ),
              ],
            ),
          ) ??
          false;
    }
    final result = await ref
        .read(noteEditorControllerProvider(widget.noteId).notifier)
        .regenerateSmartAssist(replaceTitle: replaceTitle);
    if (!mounted || result == null) return;
    if (replaceTitle && result.note.title != _titleController.text.trim()) {
      _titleController.text = result.note.title;
    }
    setState(() {
      _assistResult = result.generatedAnything ? result : null;
      _dirty = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Smart Assist regenerated')),
    );
  }

  Future<void> _attachFile() async {
    if (_dirty) await _save();
    final note =
        ref.read(noteEditorControllerProvider(widget.noteId)).asData?.value;
    if (note == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the note before adding files')),
      );
      return;
    }
    final attachment =
        await ref.read(attachmentsRepositoryProvider).pickAndAttach(note.id);
    if (!mounted) return;
    if (attachment != null) {
      await ref
          .read(noteEditorControllerProvider(widget.noteId).notifier)
          .reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attached ${attachment.fileName}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(noteEditorControllerProvider(widget.noteId));
    final spaces = ref.watch(spacesControllerProvider).asData?.value ?? [];
    final tags = ref.watch(tagsControllerProvider).asData?.value ?? [];
    final currentNote = noteAsync.asData?.value;
    final attachments = currentNote == null
        ? const <AttachmentEntity>[]
        : ref.watch(noteAttachmentsProvider(currentNote.id)).asData?.value ??
            const <AttachmentEntity>[];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_dirty) await _save();
        if (context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () async {
              if (_dirty) await _save();
              if (context.mounted) context.pop();
            },
          ),
          actions: [
            IconButton(
              tooltip: _preview ? 'Edit' : 'Preview',
              icon: Icon(
                  _preview ? Icons.edit_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _preview = !_preview),
            ),
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.check),
              onPressed: () => _save(feedback: true),
            ),
            noteAsync.maybeWhen(
              data: (note) => note == null
                  ? const SizedBox.shrink()
                  : PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'pin') {
                          await ref
                              .read(noteEditorControllerProvider(widget.noteId)
                                  .notifier)
                              .togglePin();
                        }
                        if (value == 'archive') {
                          await ref
                              .read(noteEditorControllerProvider(widget.noteId)
                                  .notifier)
                              .archive();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Moved to archive')),
                            );
                          }
                        }
                        if (value == 'smart') {
                          await _regenerateSmartAssist(note);
                        }
                        if (value == 'attach') {
                          await _attachFile();
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'pin',
                            child: Text(note.isPinned ? 'Unpin' : 'Pin')),
                        const PopupMenuItem(
                            value: 'smart',
                            child: Text('Regenerate Smart Assist')),
                        const PopupMenuItem(
                            value: 'attach', child: Text('Add attachment')),
                        const PopupMenuItem(
                            value: 'archive', child: Text('Archive')),
                      ],
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        body: noteAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (error, _) => AppEmptyState(
            icon: Icons.error_outline,
            title: 'Could not open item',
            message: '$error',
          ),
          data: (note) {
            _hydrate(note);
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Untitled',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 10),
                      NoteTypeSelector(
                        selected: _type,
                        onSelected: (type) => setState(() {
                          _type = type;
                          _dirty = true;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _MetaSelectors(
                        selectedSpaceId: _spaceId,
                        spaces: spaces,
                        selectedTagIds: _tagIds,
                        tags: tags,
                        onSpaceChanged: (value) => setState(() {
                          _spaceId = value;
                          _dirty = true;
                        }),
                        onTagToggled: (tagId) => setState(() {
                          _tagIds.contains(tagId)
                              ? _tagIds.remove(tagId)
                              : _tagIds.add(tagId);
                          _dirty = true;
                        }),
                      ),
                      if (note?.backlinks.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        _BacklinksCard(count: note!.backlinks.length),
                      ],
                      if (attachments.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _AttachmentsCard(
                          attachments: attachments,
                          onRemove: (attachmentId) async {
                            await ref
                                .read(attachmentsRepositoryProvider)
                                .remove(attachmentId);
                            await ref
                                .read(
                                    noteEditorControllerProvider(widget.noteId)
                                        .notifier)
                                .reload();
                          },
                        ),
                      ],
                      if (_assistResult != null) ...[
                        const SizedBox(height: 14),
                        _SmartAssistCard(
                          result: _assistResult!,
                          tags: tags,
                          onApplyTags: _applySuggestedTags,
                          onDismiss: () => setState(() => _assistResult = null),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: _preview
                              ? MarkdownPreview(
                                  markdown: _contentController.text)
                              : TextField(
                                  controller: _contentController,
                                  expands: true,
                                  minLines: null,
                                  maxLines: null,
                                  textAlignVertical: TextAlignVertical.top,
                                  keyboardType: TextInputType.multiline,
                                  decoration: const InputDecoration(
                                    hintText: 'Start writing in markdown...',
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.all(18),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(height: 1.65),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${MarkdownUtils.wordCount(_contentController.text)} words',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const Spacer(),
                        Text(
                            note == null
                                ? 'New item'
                                : 'Updated ${LexisDateUtils.compact(note.updatedAt)}',
                            style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SmartAssistCard extends StatelessWidget {
  const _SmartAssistCard({
    required this.result,
    required this.tags,
    required this.onApplyTags,
    required this.onDismiss,
  });

  final NoteSmartAssistResult result;
  final List<dynamic> tags;
  final ValueChanged<List<String>> onApplyTags;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final suggestedTags = tags
        .where((tag) => result.suggestedTagIds.contains(tag.id as String))
        .toList();
    final summary = result.generatedSummary?.trim();

    return AppCard(
      highlighted: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  size: 18, color: AppColors.cyanAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Smart Assist',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Dismiss',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
              ),
            ],
          ),
          if (result.generatedTitle != null) ...[
            const SizedBox(height: 8),
            _AssistLine(
              icon: Icons.title,
              label: 'Title generated',
              value: result.generatedTitle!,
            ),
          ],
          if (summary != null && summary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
          if (suggestedTags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Suggested tags',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in suggestedTags)
                  Chip(
                    label: Text(tag.name as String),
                    avatar: const Icon(Icons.sell_outlined, size: 15),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => onApplyTags(result.suggestedTagIds),
                icon: const Icon(Icons.add),
                label: const Text('Apply tags'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BacklinksCard extends StatelessWidget {
  const _BacklinksCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.account_tree_outlined,
              size: 18, color: AppColors.cyanAccent),
          const SizedBox(width: 10),
          Text(
            '$count linked note${count == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  const _AttachmentsCard({
    required this.attachments,
    required this.onRemove,
  });

  final List<AttachmentEntity> attachments;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file,
                  size: 18, color: AppColors.cyanAccent),
              const SizedBox(width: 8),
              Text('Attachments',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          for (final attachment in attachments)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(attachment.fileName),
              subtitle: Text('${attachment.sizeBytes} bytes'),
              trailing: IconButton(
                tooltip: 'Remove attachment',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onRemove(attachment.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssistLine extends StatelessWidget {
  const _AssistLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaSelectors extends StatelessWidget {
  const _MetaSelectors({
    required this.selectedSpaceId,
    required this.spaces,
    required this.selectedTagIds,
    required this.tags,
    required this.onSpaceChanged,
    required this.onTagToggled,
  });

  final String? selectedSpaceId;
  final List<dynamic> spaces;
  final List<String> selectedTagIds;
  final List<dynamic> tags;
  final ValueChanged<String?> onSpaceChanged;
  final ValueChanged<String> onTagToggled;

  @override
  Widget build(BuildContext context) {
    String? selectedSpaceName;
    for (final space in spaces) {
      if (space.id == selectedSpaceId) {
        selectedSpaceName = space.name as String;
        break;
      }
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => _showOrganizeSheet(context),
      child: Row(
        children: [
          const Icon(Icons.tune, size: 18, color: AppColors.cyanAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              [
                selectedSpaceName ?? 'No space',
                '${selectedTagIds.length} tag${selectedTagIds.length == 1 ? '' : 's'}',
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const Icon(Icons.keyboard_arrow_up, color: AppColors.textMuted),
        ],
      ),
    );
  }

  void _showOrganizeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => AppBottomSheet(
          title: 'Organize item',
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: DropdownButtonFormField<String?>(
                initialValue: selectedSpaceId,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.workspaces_outline),
                  labelText: 'Move to space',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No space'),
                  ),
                  ...spaces.map(
                    (space) => DropdownMenuItem<String?>(
                      value: space.id as String,
                      child: Text(space.name as String),
                    ),
                  ),
                ],
                onChanged: (value) {
                  onSpaceChanged(value);
                  setSheetState(() {});
                },
              ),
            ),
            if (tags.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in tags)
                        FilterChip(
                          label: Text(tag.name),
                          selected: selectedTagIds.contains(tag.id),
                          onSelected: (_) {
                            onTagToggled(tag.id as String);
                            setSheetState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
