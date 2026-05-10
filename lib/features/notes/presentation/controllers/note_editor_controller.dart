import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/app_sync.dart';
import '../../../ai_assist/application/note_smart_assist_service.dart';
import '../../../ai_assist/domain/entities/note_smart_assist_result.dart';
import '../../../archive/presentation/controllers/archive_controller.dart';
import '../../../search/presentation/controllers/search_controller.dart';
import '../../../settings/domain/entities/app_settings_entity.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../spaces/presentation/controllers/spaces_controller.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../../tags/data/repositories/tags_repository_impl.dart';
import '../../../trash/presentation/controllers/trash_controller.dart';
import '../../../vault/presentation/controllers/vault_controller.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/update_note.dart';
import 'notes_controller.dart';

final noteEditorControllerProvider =
    AsyncNotifierProvider.family<NoteEditorController, NoteEntity?, String?>(
  NoteEditorController.new,
);

class NoteEditorController extends AsyncNotifier<NoteEntity?> {
  NoteEditorController(this.noteId);

  final String? noteId;

  @override
  Future<NoteEntity?> build() async {
    if (noteId == null) return null;
    return ref.watch(notesRepositoryProvider).getById(noteId!);
  }

  Future<NoteSmartAssistResult> save({
    required String title,
    required String content,
    required NoteType type,
    required String? spaceId,
    required List<String> tagIds,
  }) async {
    final repo = ref.read(notesRepositoryProvider);
    final current = state.asData?.value;
    final saved = current == null
        ? await repo.create(
            const CreateNote()(
              title: title,
              content: content,
              type: type,
              spaceId: spaceId,
              tagIds: tagIds,
            ),
          )
        : await repo.update(
            const UpdateNote()(
              current,
              title: title,
              content: content,
              type: type,
              spaceId: spaceId,
              tagIds: tagIds,
            ),
          );
    final assistResult = await _applySmartAssist(saved);
    state = AsyncData(assistResult.note);
    _refreshDependents();
    return assistResult;
  }

  Future<NoteSmartAssistResult> _applySmartAssist(NoteEntity saved) async {
    final settings = ref.read(settingsControllerProvider).asData?.value ??
        AppSettingsEntity.defaults();
    if (!settings.smartAssistEnabled) {
      return NoteSmartAssistResult(note: saved);
    }

    final tags = await ref.read(tagsRepositoryProvider).getAll();
    final suggestion = ref.read(noteSmartAssistServiceProvider).suggest(
          note: saved,
          availableTags: tags,
          settings: settings,
        );

    final nextTitle = suggestion.generatedTitle ?? saved.title;
    final nextSummary = suggestion.generatedSummary ?? saved.summary;
    final shouldUpdateNote =
        nextTitle != saved.title || nextSummary != saved.summary;
    final visibleGeneratedTitle =
        nextTitle != saved.title ? suggestion.generatedTitle : null;
    final visibleGeneratedSummary =
        nextSummary != saved.summary ? suggestion.generatedSummary : null;

    if (!shouldUpdateNote) {
      return NoteSmartAssistResult(
        note: saved,
        generatedTitle: visibleGeneratedTitle,
        generatedSummary: visibleGeneratedSummary,
        suggestedTagIds: suggestion.suggestedTagIds,
      );
    }

    final updated = await ref.read(notesRepositoryProvider).update(
          saved.copyWith(
            title: nextTitle,
            summary: nextSummary,
            updatedAt: DateTime.now(),
          ),
        );

    return NoteSmartAssistResult(
      note: updated,
      generatedTitle: visibleGeneratedTitle,
      generatedSummary: visibleGeneratedSummary,
      suggestedTagIds: suggestion.suggestedTagIds,
    );
  }

  Future<NoteEntity?> applySuggestedTags(List<String> tagIds) async {
    final note = state.asData?.value;
    if (note == null || tagIds.isEmpty) return note;
    final merged = {...note.tagIds, ...tagIds}.toList();
    final updated = await ref.read(notesRepositoryProvider).update(
          note.copyWith(tagIds: merged, updatedAt: DateTime.now()),
        );
    state = AsyncData(updated);
    _refreshDependents();
    return updated;
  }

  Future<void> togglePin() async {
    final note = state.asData?.value;
    if (note == null) return;
    await ref.read(notesRepositoryProvider).togglePin(note.id);
    state = AsyncData(await ref.read(notesRepositoryProvider).getById(note.id));
    _refreshDependents();
  }

  Future<void> archive() async {
    final note = state.asData?.value;
    if (note == null) return;
    await ref.read(notesRepositoryProvider).archive(note.id);
    state = AsyncData(await ref.read(notesRepositoryProvider).getById(note.id));
    _refreshDependents();
  }

  void _refreshDependents() {
    notifyAppDataChanged(ref);
    ref.invalidate(vaultControllerProvider);
    ref.invalidate(notesControllerProvider);
    ref.invalidate(archiveControllerProvider);
    ref.invalidate(trashControllerProvider);
    ref.invalidate(spacesControllerProvider);
    ref.invalidate(tagsControllerProvider);
    ref.invalidate(searchControllerProvider);
  }
}
