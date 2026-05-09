import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../folders/presentation/notifiers/folders_notifier.dart';
import '../../../tags/presentation/notifiers/tags_notifier.dart';
import '../../data/note_model.dart';
import '../notifiers/notes_notifier.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.note, this.folderId});

  final Note? note;
  final int? folderId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _previewMode = false;
  bool _isDirty = false;
  bool _isSaved = false;
  late Note? _note;
  List<int> _selectedTagIds = [];
  int? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _selectedTagIds = widget.note?.tagIds ?? [];
    _selectedFolderId = widget.note?.folderId ?? widget.folderId;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _titleController.addListener(_markDirty);
    _contentController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_isDirty) return;
    final title = _titleController.text.trim();
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty && _note == null) return;

    final notifier = ref.read(notesProvider.notifier);
    if (_note == null) {
      final id = await notifier.createNote(
        title: title,
        content: content,
        folderId: _selectedFolderId,
      );
      if (mounted) {
        // Add tags to the new note
        for (final tagId in _selectedTagIds) {
          await notifier.addTagToNote(id, tagId);
        }
        
        setState(() {
          _note = Note(
            id: id,
            uuid: '',
            title: title,
            content: content,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isPinned: false,
            isArchived: false,
            folderId: _selectedFolderId,
            tagIds: _selectedTagIds,
          );
          _isDirty = false;
          _isSaved = true;
        });
        
        // Hide the saved indicator after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isSaved = false);
          }
        });
      }
    } else {
      await notifier.updateNote(_note!.id, title: title, content: content);
      await notifier.moveToFolder(_note!.id, _selectedFolderId);
      
      // Update tags - remove old tags and add new ones
      final oldTagIds = _note!.tagIds;
      final tagsToRemove = oldTagIds.where((id) => !_selectedTagIds.contains(id)).toList();
      final tagsToAdd = _selectedTagIds.where((id) => !oldTagIds.contains(id)).toList();
      
      for (final tagId in tagsToRemove) {
        await notifier.removeTagFromNote(_note!.id, tagId);
      }
      for (final tagId in tagsToAdd) {
        await notifier.addTagToNote(_note!.id, tagId);
      }
      
      if (mounted) {
        setState(() {
          _note = _note!.copyWith(
            title: title,
            content: content,
            updatedAt: DateTime.now(),
            folderId: _selectedFolderId,
            tagIds: _selectedTagIds,
          );
          _isDirty = false;
          _isSaved = true;
        });
        
        // Hide the saved indicator after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isSaved = false);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _save();
          if (context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          title: _isSaved
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Saved',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : null,
          actions: [
            if (_note != null || _selectedFolderId != null)
              IconButton(
                icon: Icon(Icons.folder, size: 22, color: AppColors.secondary),
                onPressed: _showFolderPicker,
                tooltip: 'Change Folder',
              ),
            IconButton(
              icon: Icon(Icons.label_outline, size: 22, color: AppColors.secondary),
              onPressed: _showTagPicker,
              tooltip: 'Add Tags',
            ),
            IconButton(
              icon: Icon(
                _previewMode ? Icons.edit_outlined : Icons.visibility_outlined,
                size: 22,
              ),
              tooltip: _previewMode ? 'Edit' : 'Preview',
              onPressed: () => setState(() => _previewMode = !_previewMode),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.hint),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            Expanded(
              child: _previewMode
                  ? Markdown(
                      data: _contentController.text.isEmpty 
                          ? '_No content_' 
                          : _contentController.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        h1: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        code: const TextStyle(
                          color: AppColors.accent,
                          backgroundColor: AppColors.surfaceHigh,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        blockquote: const TextStyle(
                          color: AppColors.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: AppColors.border, width: 4),
                          ),
                        ),
                        horizontalRuleDecoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.border, width: 1),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    )
                  : TextField(
                      controller: _contentController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        height: 1.6,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Start writing...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.hint),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                    ),
            ),
          ],
        ),
        bottomNavigationBar: _previewMode
            ? null
            : _MarkdownToolbar(controller: _contentController),
      ),
    );
  }

  Future<void> _showTagPicker() async {
    final allTags = await ref.read(tagsProvider.future);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceHigh,
          title: const Text('Select Tags'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTags.map((tag) {
                    final isSelected = _selectedTagIds.contains(tag.id);
                    return FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      selectedColor: _hexToColor(tag.colorHex).withOpacity(0.3),
                      backgroundColor: _hexToColor(tag.colorHex).withOpacity(0.1),
                      checkmarkColor: _hexToColor(tag.colorHex),
                      labelStyle: TextStyle(
                        color: isSelected ? _hexToColor(tag.colorHex) : AppColors.primary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            _selectedTagIds.add(tag.id);
                          } else {
                            _selectedTagIds.remove(tag.id);
                          }
                        });
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.secondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _markDirty();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFolderPicker() async {
    final allFolders = await ref.read(foldersProvider.future);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceHigh,
          title: const Text('Select Folder'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<int?>(
                      title: const Text('No Folder'),
                      value: null,
                      groupValue: _selectedFolderId,
                      activeColor: AppColors.accent,
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedFolderId = value;
                        });
                        setState(() {});
                      },
                    ),
                    ...allFolders.map((folder) {
                      return RadioListTile<int>(
                        title: Text(folder.name),
                        value: folder.id,
                        groupValue: _selectedFolderId,
                        activeColor: AppColors.accent,
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedFolderId = value;
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.secondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _markDirty();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.accent;
    }
  }
}

class _MarkdownToolbar extends StatelessWidget {
  const _MarkdownToolbar({required this.controller});
  final TextEditingController controller;

  void _wrap(String before, String after) {
    final sel = controller.selection;
    if (!sel.isValid) {
      final text = controller.text;
      controller.value = controller.value.copyWith(
        text: text + before + after,
        selection: TextSelection.collapsed(offset: text.length + before.length),
      );
      return;
    }
    final text = controller.text;
    final selected = sel.textInside(text);
    final newText = text.replaceRange(
      sel.start,
      sel.end,
      '$before$selected$after',
    );
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: sel.start + before.length + selected.length,
      ),
    );
  }

  void _insertAtLineStart(String prefix) {
    final sel = controller.selection;
    final text = controller.text;
    
    int lineStart;
    if (!sel.isValid || sel.start == 0) {
      lineStart = 0;
    } else {
      lineStart = text.lastIndexOf('\n', sel.start - 1) + 1;
    }

    final newText = text.substring(0, lineStart) + prefix + text.substring(lineStart);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: (sel.isValid ? sel.baseOffset : text.length) + prefix.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 0
            : MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ToolBtn(Icons.format_bold, () => _wrap('**', '**')),
                _ToolBtn(Icons.format_italic, () => _wrap('_', '_')),
                _ToolBtn(Icons.code, () => _wrap('`', '`')),
                _ToolDivider(),
                _ToolTextBtn('H1', () => _insertAtLineStart('# ')),
                _ToolTextBtn('H2', () => _insertAtLineStart('## ')),
                _ToolTextBtn('H3', () => _insertAtLineStart('### ')),
                _ToolDivider(),
                _ToolBtn(Icons.format_list_bulleted, () => _insertAtLineStart('- ')),
                _ToolBtn(Icons.format_list_numbered, () => _insertAtLineStart('1. ')),
                _ToolBtn(Icons.format_quote, () => _insertAtLineStart('> ')),
                _ToolBtn(Icons.horizontal_rule, () {
                  final pos = controller.selection.baseOffset;
                  final text = controller.text;
                  final newText = pos == -1 
                      ? '$text\n---\n' 
                      : '${text.substring(0, pos)}\n---\n${text.substring(pos)}';
                  controller.value = controller.value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(offset: (pos == -1 ? text.length : pos) + 5),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn(this.icon, this.onTap);
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: AppColors.secondary),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ToolTextBtn extends StatelessWidget {
  const _ToolTextBtn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ToolDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.border,
    );
  }
}
