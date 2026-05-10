import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.cyanAccent,
      ),
    );
  }
}
