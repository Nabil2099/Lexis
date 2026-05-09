// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folders_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FoldersNotifier)
final foldersProvider = FoldersNotifierProvider._();

final class FoldersNotifierProvider
    extends $AsyncNotifierProvider<FoldersNotifier, List<Folder>> {
  FoldersNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'foldersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$foldersNotifierHash();

  @$internal
  @override
  FoldersNotifier create() => FoldersNotifier();
}

String _$foldersNotifierHash() => r'47a2bbed480fb2d75fb4ec7a77682c438f212b33';

abstract class _$FoldersNotifier extends $AsyncNotifier<List<Folder>> {
  FutureOr<List<Folder>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Folder>>, List<Folder>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Folder>>, List<Folder>>,
        AsyncValue<List<Folder>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
