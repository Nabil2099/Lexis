import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        loading: () => const AppLoadingState(),
        error: (error, _) => AppErrorState(error: error),
        data: (value) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            const AppSectionHeader(
              title: 'Workspace',
              subtitle: 'Tune the writing experience.',
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('True black mode'),
                    subtitle:
                        const Text('Use pure black surfaces where possible.'),
                    value: value.useTrueBlack,
                    onChanged: (next) => ref
                        .read(settingsControllerProvider.notifier)
                        .applySettings(value.copyWith(useTrueBlack: next)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Markdown preview by default'),
                    value: value.useMarkdownPreview,
                    onChanged: (next) => ref
                        .read(settingsControllerProvider.notifier)
                        .applySettings(
                            value.copyWith(useMarkdownPreview: next)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Confirm before delete'),
                    value: value.confirmBeforeDelete,
                    onChanged: (next) => ref
                        .read(settingsControllerProvider.notifier)
                        .applySettings(
                            value.copyWith(confirmBeforeDelete: next)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Show word count'),
                    value: value.showWordCount,
                    onChanged: (next) => ref
                        .read(settingsControllerProvider.notifier)
                        .applySettings(value.copyWith(showWordCount: next)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(
              title: 'Smart Assist',
              subtitle:
                  'Private, offline suggestions for titles, summaries, and tags.',
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.auto_awesome_outlined),
                    title: const Text('Enable Smart Assist'),
                    subtitle: const Text(
                        'Run local suggestions after saving a note.'),
                    value: value.smartAssistEnabled,
                    onChanged: (next) => ref
                        .read(settingsControllerProvider.notifier)
                        .applySettings(
                            value.copyWith(smartAssistEnabled: next)),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Auto-title empty notes'),
                    value: value.smartAssistAutoTitle,
                    onChanged: value.smartAssistEnabled
                        ? (next) => ref
                            .read(settingsControllerProvider.notifier)
                            .applySettings(
                                value.copyWith(smartAssistAutoTitle: next))
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Generate summaries'),
                    value: value.smartAssistAutoSummary,
                    onChanged: value.smartAssistEnabled
                        ? (next) => ref
                            .read(settingsControllerProvider.notifier)
                            .applySettings(
                                value.copyWith(smartAssistAutoSummary: next))
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Suggest matching tags'),
                    value: value.smartAssistSuggestTags,
                    onChanged: value.smartAssistEnabled
                        ? (next) => ref
                            .read(settingsControllerProvider.notifier)
                            .applySettings(
                                value.copyWith(smartAssistSuggestTags: next))
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Vault'),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: const Text('Archive'),
                    onTap: () => context.push(AppRoutes.archive),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Trash'),
                    onTap: () => context.push(AppRoutes.trash),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.file_upload_outlined),
                    title: Text('Export data'),
                    subtitle: Text('Coming soon'),
                    enabled: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(
              title: 'Data',
              subtitle: 'Local-only actions for this device.',
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: AppColors.danger,
                ),
                title: const Text(
                  'Clear all data',
                  style: TextStyle(color: AppColors.danger),
                ),
                subtitle: const Text(
                    'Delete all notes, spaces, tags, settings, and trash.'),
                onTap: () async {
                  final confirmed = await showAppConfirmDialog(
                    context,
                    title: 'Clear all Lexis data?',
                    message:
                        'This permanently removes everything stored locally in Hive.',
                    confirmLabel: 'Clear',
                    destructive: true,
                  );
                  if (confirmed) {
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .clearAllData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('All local data cleared')));
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            const AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.lock_outline, color: AppColors.cyanAccent),
                title: Text('Lexis'),
                subtitle: Text(
                    'Offline Knowledge Vault\nCapture anything. Organize your mind. Keep it private.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
