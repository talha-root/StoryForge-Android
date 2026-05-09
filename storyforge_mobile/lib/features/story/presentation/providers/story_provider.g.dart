// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storyDetailHash() => r'e96dbecb76d3e1fc4cdd4ba2b56b0ca8c942424b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$StoryDetail
    extends BuildlessAutoDisposeAsyncNotifier<StoryModel?> {
  late final String id;

  FutureOr<StoryModel?> build(String id);
}

/// See also [StoryDetail].
@ProviderFor(StoryDetail)
const storyDetailProvider = StoryDetailFamily();

/// See also [StoryDetail].
class StoryDetailFamily extends Family<AsyncValue<StoryModel?>> {
  /// See also [StoryDetail].
  const StoryDetailFamily();

  /// See also [StoryDetail].
  StoryDetailProvider call(String id) {
    return StoryDetailProvider(id);
  }

  @override
  StoryDetailProvider getProviderOverride(
    covariant StoryDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'storyDetailProvider';
}

/// See also [StoryDetail].
class StoryDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<StoryDetail, StoryModel?> {
  /// See also [StoryDetail].
  StoryDetailProvider(String id)
    : this._internal(
        () => StoryDetail()..id = id,
        from: storyDetailProvider,
        name: r'storyDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$storyDetailHash,
        dependencies: StoryDetailFamily._dependencies,
        allTransitiveDependencies: StoryDetailFamily._allTransitiveDependencies,
        id: id,
      );

  StoryDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  FutureOr<StoryModel?> runNotifierBuild(covariant StoryDetail notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(StoryDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: StoryDetailProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<StoryDetail, StoryModel?>
  createElement() {
    return _StoryDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoryDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StoryDetailRef on AutoDisposeAsyncNotifierProviderRef<StoryModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _StoryDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<StoryDetail, StoryModel?>
    with StoryDetailRef {
  _StoryDetailProviderElement(super.provider);

  @override
  String get id => (origin as StoryDetailProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
