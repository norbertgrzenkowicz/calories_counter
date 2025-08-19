// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasProfileHash() => r'6b9ff93c8d902e3d964ce9d7bd5b79341a64b309';

/// Provider for checking if profile exists
///
/// Copied from [hasProfile].
@ProviderFor(hasProfile)
final hasProfileProvider = AutoDisposeProvider<bool>.internal(
  hasProfile,
  name: r'hasProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hasProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasProfileRef = AutoDisposeProviderRef<bool>;
String _$dailyCalorieTargetHash() =>
    r'0389173c28d14acbd4990be4d3829002c188a770';

/// Provider for getting daily calorie target
///
/// Copied from [dailyCalorieTarget].
@ProviderFor(dailyCalorieTarget)
final dailyCalorieTargetProvider = AutoDisposeProvider<int>.internal(
  dailyCalorieTarget,
  name: r'dailyCalorieTargetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyCalorieTargetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyCalorieTargetRef = AutoDisposeProviderRef<int>;
String _$profileNotifierHash() => r'b383852ca193492e80368798d2d20eade7bb3480';

/// User profile state notifier
///
/// Copied from [ProfileNotifier].
@ProviderFor(ProfileNotifier)
final profileNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ProfileNotifier, UserProfile?>.internal(
  ProfileNotifier.new,
  name: r'profileNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileNotifier = AutoDisposeAsyncNotifier<UserProfile?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
