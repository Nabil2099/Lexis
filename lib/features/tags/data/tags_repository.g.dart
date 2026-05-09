// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tagsRepository)
final tagsRepositoryProvider = TagsRepositoryProvider._();

final class TagsRepositoryProvider
    extends $FunctionalProvider<TagsRepository, TagsRepository, TagsRepository>
    with $Provider<TagsRepository> {
  TagsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TagsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagsRepository create(Ref ref) {
    return tagsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagsRepository>(value),
    );
  }
}

String _$tagsRepositoryHash() => r'37974966cca297c9f3e952ab60214e32d80f3f9f';
