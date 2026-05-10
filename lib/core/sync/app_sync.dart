import 'package:flutter_riverpod/flutter_riverpod.dart';

final appSyncSignalProvider =
    NotifierProvider<AppSyncSignal, int>(AppSyncSignal.new);

class AppSyncSignal extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state += 1;
}

void notifyAppDataChanged(Ref ref) {
  ref.read(appSyncSignalProvider.notifier).bump();
}
