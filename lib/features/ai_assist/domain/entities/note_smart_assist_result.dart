import '../../../notes/domain/entities/note_entity.dart';

class NoteSmartAssistResult {
  const NoteSmartAssistResult({
    required this.note,
    this.generatedTitle,
    this.generatedSummary,
    this.suggestedTagIds = const [],
  });

  final NoteEntity note;
  final String? generatedTitle;
  final String? generatedSummary;
  final List<String> suggestedTagIds;

  bool get generatedAnything =>
      generatedTitle != null ||
      generatedSummary != null ||
      suggestedTagIds.isNotEmpty;
}
