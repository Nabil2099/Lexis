import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.color,
    this.onTap,
  });

  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor:
            selected ? chipColor.withValues(alpha: 0.18) : AppColors.surface,
        side: BorderSide(
          color: selected
              ? AppColors.cyanAccent.withValues(alpha: 0.75)
              : AppColors.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        avatar: selected
            ? const Icon(Icons.check, size: 15, color: AppColors.cyanAccent)
            : null,
        labelStyle: TextStyle(
          color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          height: 1,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
