import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../settings/presentation/controllers/settings_controller.dart';
import '../application/app_lock_service.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _unlocked = false;
  bool _authenticating = false;
  bool _supportChecked = false;
  bool _supported = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).asData?.value;
    if (settings?.appLockEnabled != true || _unlocked) {
      return widget.child;
    }
    if (!_supportChecked) {
      _checkSupport();
      return widget.child;
    }
    if (!_supported) {
      return widget.child;
    }

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.cyanAccent,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                Text('Lexis is locked',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Authenticate to open your private vault.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _authenticating ? null : _unlock,
                  icon: _authenticating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fingerprint),
                  label: const Text('Unlock Lexis'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkSupport() async {
    final supported = await ref.read(appLockServiceProvider).canAuthenticate();
    if (!mounted) return;
    setState(() {
      _supportChecked = true;
      _supported = supported;
    });
  }

  Future<void> _unlock() async {
    setState(() => _authenticating = true);
    final success = await ref.read(appLockServiceProvider).unlock();
    if (!mounted) return;
    setState(() {
      _authenticating = false;
      _unlocked = success;
    });
  }
}
