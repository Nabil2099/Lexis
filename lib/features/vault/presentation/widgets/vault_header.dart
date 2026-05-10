import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class VaultHeader extends StatelessWidget {
  const VaultHeader({
    super.key,
    required this.noteCount,
    required this.spaceCount,
    required this.tagCount,
  });

  final int noteCount;
  final int spaceCount;
  final int tagCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceHigh.withValues(alpha: 0.88),
            AppColors.surface.withValues(alpha: 0.58),
          ],
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cyanAccent.withValues(alpha: 0.28),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 19,
                    color: AppColors.cyanAccent,
                  ),
                ),
                const Spacer(),
                Text('PRIVATE', style: AppTextStyles.muted),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Your Vault', style: AppTextStyles.title),
            const SizedBox(height: 6),
            const Text(
              'Capture anything. Organize your mind. Keep it private.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Metric(label: 'Notes', value: noteCount),
                _Metric(label: 'Spaces', value: spaceCount),
                _Metric(label: 'Tags', value: tagCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$value $label',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
