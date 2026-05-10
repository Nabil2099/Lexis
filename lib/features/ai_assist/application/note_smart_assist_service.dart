import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/markdown_utils.dart';
import '../../notes/domain/entities/note_entity.dart';
import '../../settings/domain/entities/app_settings_entity.dart';
import '../../tags/domain/entities/tag_entity.dart';
import '../domain/entities/note_smart_assist_result.dart';

final noteSmartAssistServiceProvider = Provider<NoteSmartAssistService>((ref) {
  return const NoteSmartAssistService();
});

class NoteSmartAssistService {
  const NoteSmartAssistService();

  NoteSmartAssistResult suggest({
    required NoteEntity note,
    required List<TagEntity> availableTags,
    required AppSettingsEntity settings,
  }) {
    if (!settings.smartAssistEnabled || note.content.trim().isEmpty) {
      return NoteSmartAssistResult(note: note);
    }

    final plainText = note.plainText.trim().isNotEmpty
        ? note.plainText.trim()
        : MarkdownUtils.toPlainText(note.content);
    if (plainText.isEmpty) return NoteSmartAssistResult(note: note);

    final generatedTitle =
        settings.smartAssistAutoTitle && _canGenerateTitle(note.title)
            ? _titleFromMarkdown(note.content) ?? _titleFromText(plainText)
            : null;
    final generatedSummary =
        settings.smartAssistAutoSummary ? _summaryFromText(plainText) : null;
    final suggestedTagIds = settings.smartAssistSuggestTags
        ? _suggestTags(
            note: note,
            availableTags: availableTags,
            generatedTitle: generatedTitle,
          )
        : const <String>[];

    return NoteSmartAssistResult(
      note: note,
      generatedTitle: generatedTitle,
      generatedSummary: generatedSummary,
      suggestedTagIds: suggestedTagIds,
    );
  }

  bool _canGenerateTitle(String title) {
    final normalized = title.trim().toLowerCase();
    return normalized.isEmpty || normalized == 'untitled';
  }

  String? _titleFromMarkdown(String markdown) {
    final heading = RegExp(r'^\s{0,3}#{1,6}\s+(.+)$', multiLine: true)
        .firstMatch(markdown)
        ?.group(1);
    return _cleanTitle(heading);
  }

  String? _titleFromText(String text) {
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final sentenceTitle =
        _cleanTitle(sentences.isEmpty ? null : sentences.first);
    if (sentenceTitle != null) return sentenceTitle;

    final lines = text
        .split(RegExp(r'[\n\r]+'))
        .map(_cleanTitle)
        .whereType<String>()
        .where((line) => line.length > 2);
    if (lines.isNotEmpty) return lines.first;
    return null;
  }

  String? _cleanTitle(String? value) {
    if (value == null) return null;
    final cleaned = value
        .replaceAll(RegExp(r'^\s*[-*+>\d.)\[\]xX]+\s*'), '')
        .replaceAll(RegExp(r'[*_`~#]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return null;
    return _truncate(cleaned, 68);
  }

  String? _summaryFromText(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return null;
    if (cleaned.length <= 180) return cleaned;

    final sentences = cleaned
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((sentence) => sentence.trim())
        .where((sentence) => sentence.length > 18)
        .toList();

    if (sentences.isEmpty) return _truncate(cleaned, 180);

    final buffer = StringBuffer(sentences.first);
    if (sentences.length > 1 && buffer.length < 110) {
      final candidate = '${buffer.toString()} ${sentences[1]}';
      if (candidate.length <= 180) buffer.write(' ${sentences[1]}');
    }
    return _truncate(buffer.toString(), 180);
  }

  List<String> _suggestTags({
    required NoteEntity note,
    required List<TagEntity> availableTags,
    required String? generatedTitle,
  }) {
    final existing = note.tagIds.toSet();
    final haystack = _normalizeForSearch(
      [
        note.title,
        generatedTitle,
        note.plainText,
        MarkdownUtils.toPlainText(note.content),
      ].whereType<String>().join(' '),
    );
    final words = haystack.split(' ').where((word) => word.isNotEmpty).toSet();

    final ranked = <_TagRank>[];
    for (final tag in availableTags) {
      if (existing.contains(tag.id)) continue;
      final normalizedName = _normalizeForSearch(tag.name);
      if (normalizedName.isEmpty) continue;

      var score = 0;
      if (haystack.contains(normalizedName)) score += 3;
      for (final part in normalizedName.split(' ')) {
        if (part.length > 2 && words.contains(part)) score += 2;
        if (part.length > 3 && words.contains(_singularize(part))) score += 1;
      }
      if (score > 0) ranked.add(_TagRank(tag.id, score, tag.name));
    }

    ranked.sort((a, b) {
      final score = b.score.compareTo(a.score);
      if (score != 0) return score;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return ranked.take(5).map((rank) => rank.id).toList();
  }

  String _normalizeForSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _singularize(String value) {
    if (value.length > 3 && value.endsWith('ies')) {
      return '${value.substring(0, value.length - 3)}y';
    }
    if (value.length > 3 && value.endsWith('s')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    final soft = value.substring(0, maxLength).trimRight();
    final lastSpace = soft.lastIndexOf(' ');
    final next = lastSpace > 48 ? soft.substring(0, lastSpace) : soft;
    return '${next.replaceAll(RegExp(r'[,.!?;:]+$'), '')}...';
  }
}

class _TagRank {
  const _TagRank(this.id, this.score, this.name);

  final String id;
  final int score;
  final String name;
}
