import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/app_colors.dart';

class MarkdownPreview extends StatelessWidget {
  const MarkdownPreview({super.key, required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: markdown.trim().isEmpty ? '_Nothing to preview yet._' : markdown,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
            color: AppColors.textPrimary, height: 1.55, fontSize: 15),
        h1: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800),
        h2: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700),
        h3: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700),
        code: const TextStyle(
          color: AppColors.cyanAccent,
          backgroundColor: AppColors.surfaceHigh,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        blockquoteDecoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
        ),
        blockquote: const TextStyle(
            color: AppColors.textSecondary, fontStyle: FontStyle.italic),
      ),
    );
  }
}
