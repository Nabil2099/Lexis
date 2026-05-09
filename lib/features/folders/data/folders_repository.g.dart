// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folders_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(foldersRepository)
final foldersRepositoryProvider = FoldersRepositoryProvider._();

final class FoldersRepositoryProvider extends $FunctionalProvider<
    FoldersRepository,
    FoldersRepository,
    FoldersRepository> with $Provider<FoldersRepository> {
  FoldersRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'foldersRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$foldersRepositoryHash();

  @$internal
  @override
  $ProviderElement<FoldersRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FoldersRepository create(Ref ref) {
    return foldersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoldersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoldersRepository>(value),
    );
  }
}

String _$foldersRepositoryHash() => r'53d6fb0bcc77110d5e73106e14608b1092f6b24c';
