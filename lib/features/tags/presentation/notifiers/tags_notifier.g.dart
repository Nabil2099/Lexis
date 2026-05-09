// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TagsNotifier)
final tagsProvider = TagsNotifierProvider._();

final class TagsNotifierProvider
    extends $AsyncNotifierProvider<TagsNotifier, List<Tag>> {
  TagsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagsNotifierHash();

  @$internal
  @override
  TagsNotifier create() => TagsNotifier();
}

String _$tagsNotifierHash() => r'06da37d59d2bc5cc026edf0bb5f1b74a86ef8d3b';

abstract class _$TagsNotifier extends $AsyncNotifier<List<Tag>> {
  FutureOr<List<Tag>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Tag>>, List<Tag>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Tag>>, List<Tag>>,
        AsyncValue<List<Tag>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
