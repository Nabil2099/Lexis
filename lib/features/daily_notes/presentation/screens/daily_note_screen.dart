import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../application/daily_notes_service.dart';

class DailyNoteScreen extends ConsumerWidget {
  const DailyNoteScreen({super.key, required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.tryParse(dateKey) ?? DateTime.now();
    return FutureBuilder(
      future: ref.read(dailyNotesServiceProvider).getOrCreate(date),
      builder: (context, snapshot) {
        if (snapshot.hasError) return AppErrorState(error: snapshot.error!);
        if (!snapshot.hasData) {
          return const Scaffold(body: AppLoadingState());
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.replace('/note/${snapshot.data!.id}');
        });
        return const Scaffold(body: AppLoadingState());
      },
    );
  }
}
