import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';

class LexisApp extends ConsumerWidget {
  const LexisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).asData?.value;
    final theme =
        AppTheme.darkTheme(useTrueBlack: settings?.useTrueBlack ?? true);

    return MaterialApp.router(
      title: 'Lexis',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
