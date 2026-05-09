// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotesNotifier)
final notesProvider = NotesNotifierProvider._();

final class NotesNotifierProvider
    extends $AsyncNotifierProvider<NotesNotifier, List<Note>> {
  NotesNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notesNotifierHash();

  @$internal
  @override
  NotesNotifier create() => NotesNotifier();
}

String _$notesNotifierHash() => r'fff676152fdad46722529aed6b7debd013cc57a1';

abstract class _$NotesNotifier extends $AsyncNotifier<List<Note>> {
  FutureOr<List<Note>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Note>>, List<Note>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Note>>, List<Note>>,
        AsyncValue<List<Note>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ArchivedNotesNotifier)
final archivedNotesProvider = ArchivedNotesNotifierProvider._();

final class ArchivedNotesNotifierProvider
    extends $AsyncNotifierProvider<ArchivedNotesNotifier, List<Note>> {
  ArchivedNotesNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'archivedNotesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$archivedNotesNotifierHash();

  @$internal
  @override
  ArchivedNotesNotifier create() => ArchivedNotesNotifier();
}

String _$archivedNotesNotifierHash() =>
    r'174a1c1016306ef73e00c296cce2ecf345bf237f';

abstract class _$ArchivedNotesNotifier extends $AsyncNotifier<List<Note>> {
  FutureOr<List<Note>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Note>>, List<Note>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Note>>, List<Note>>,
        AsyncValue<List<Note>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FolderNotesNotifier)
final folderNotesProvider = FolderNotesNotifierFamily._();

final class FolderNotesNotifierProvider
    extends $AsyncNotifierProvider<FolderNotesNotifier, List<Note>> {
  FolderNotesNotifierProvider._(
      {required FolderNotesNotifierFamily super.from,
      required FolderNotesParam super.argument})
      : super(
          retry: null,
          name: r'folderNotesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$folderNotesNotifierHash();

  @override
  String toString() {
    return r'folderNotesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FolderNotesNotifier create() => FolderNotesNotifier();

  @override
  bool operator ==(Object other) {
    return other is FolderNotesNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$folderNotesNotifierHash() =>
    r'd7063fb5c73ce47194a07e9cad4d10899cd3ce9b';

final class FolderNotesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<FolderNotesNotifier, AsyncValue<List<Note>>,
            List<Note>, FutureOr<List<Note>>, FolderNotesParam> {
  FolderNotesNotifierFamily._()
      : super(
          retry: null,
          name: r'folderNotesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FolderNotesNotifierProvider call(
    FolderNotesParam param,
  ) =>
      FolderNotesNotifierProvider._(argument: param, from: this);

  @override
  String toString() => r'folderNotesProvider';
}

abstract class _$FolderNotesNotifier extends $AsyncNotifier<List<Note>> {
  late final _$args = ref.$arg as FolderNotesParam;
  FolderNotesParam get param => _$args;

  FutureOr<List<Note>> build(
    FolderNotesParam param,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Note>>, List<Note>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Note>>, List<Note>>,
        AsyncValue<List<Note>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
