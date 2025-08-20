// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allUserMealsHash() => r'07f7f790c277c74cc621fb6fd1c1c664dfa6711a';

/// Provider for getting all user meals
///
/// Copied from [allUserMeals].
@ProviderFor(allUserMeals)
final allUserMealsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  allUserMeals,
  name: r'allUserMealsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allUserMealsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllUserMealsRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$dailyNutritionTotalsHash() =>
    r'323c1537438f3f295f53805a79e99da9604a4bb6';

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

/// Provider for calculating daily nutrition totals
///
/// Copied from [dailyNutritionTotals].
@ProviderFor(dailyNutritionTotals)
const dailyNutritionTotalsProvider = DailyNutritionTotalsFamily();

/// Provider for calculating daily nutrition totals
///
/// Copied from [dailyNutritionTotals].
class DailyNutritionTotalsFamily extends Family<Map<String, num>> {
  /// Provider for calculating daily nutrition totals
  ///
  /// Copied from [dailyNutritionTotals].
  const DailyNutritionTotalsFamily();

  /// Provider for calculating daily nutrition totals
  ///
  /// Copied from [dailyNutritionTotals].
  DailyNutritionTotalsProvider call(
    DateTime date,
  ) {
    return DailyNutritionTotalsProvider(
      date,
    );
  }

  @override
  DailyNutritionTotalsProvider getProviderOverride(
    covariant DailyNutritionTotalsProvider provider,
  ) {
    return call(
      provider.date,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dailyNutritionTotalsProvider';
}

/// Provider for calculating daily nutrition totals
///
/// Copied from [dailyNutritionTotals].
class DailyNutritionTotalsProvider
    extends AutoDisposeProvider<Map<String, num>> {
  /// Provider for calculating daily nutrition totals
  ///
  /// Copied from [dailyNutritionTotals].
  DailyNutritionTotalsProvider(
    DateTime date,
  ) : this._internal(
          (ref) => dailyNutritionTotals(
            ref as DailyNutritionTotalsRef,
            date,
          ),
          from: dailyNutritionTotalsProvider,
          name: r'dailyNutritionTotalsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyNutritionTotalsHash,
          dependencies: DailyNutritionTotalsFamily._dependencies,
          allTransitiveDependencies:
              DailyNutritionTotalsFamily._allTransitiveDependencies,
          date: date,
        );

  DailyNutritionTotalsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    Map<String, num> Function(DailyNutritionTotalsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyNutritionTotalsProvider._internal(
        (ref) => create(ref as DailyNutritionTotalsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Map<String, num>> createElement() {
    return _DailyNutritionTotalsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyNutritionTotalsProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyNutritionTotalsRef on AutoDisposeProviderRef<Map<String, num>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _DailyNutritionTotalsProviderElement
    extends AutoDisposeProviderElement<Map<String, num>>
    with DailyNutritionTotalsRef {
  _DailyNutritionTotalsProviderElement(super.provider);

  @override
  DateTime get date => (origin as DailyNutritionTotalsProvider).date;
}

String _$dailyMealCountHash() => r'654aeb7b660931eb1db911efe7de1fd8d5ae98a7';

/// Provider for meal count for a specific date
///
/// Copied from [dailyMealCount].
@ProviderFor(dailyMealCount)
const dailyMealCountProvider = DailyMealCountFamily();

/// Provider for meal count for a specific date
///
/// Copied from [dailyMealCount].
class DailyMealCountFamily extends Family<int> {
  /// Provider for meal count for a specific date
  ///
  /// Copied from [dailyMealCount].
  const DailyMealCountFamily();

  /// Provider for meal count for a specific date
  ///
  /// Copied from [dailyMealCount].
  DailyMealCountProvider call(
    DateTime date,
  ) {
    return DailyMealCountProvider(
      date,
    );
  }

  @override
  DailyMealCountProvider getProviderOverride(
    covariant DailyMealCountProvider provider,
  ) {
    return call(
      provider.date,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dailyMealCountProvider';
}

/// Provider for meal count for a specific date
///
/// Copied from [dailyMealCount].
class DailyMealCountProvider extends AutoDisposeProvider<int> {
  /// Provider for meal count for a specific date
  ///
  /// Copied from [dailyMealCount].
  DailyMealCountProvider(
    DateTime date,
  ) : this._internal(
          (ref) => dailyMealCount(
            ref as DailyMealCountRef,
            date,
          ),
          from: dailyMealCountProvider,
          name: r'dailyMealCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyMealCountHash,
          dependencies: DailyMealCountFamily._dependencies,
          allTransitiveDependencies:
              DailyMealCountFamily._allTransitiveDependencies,
          date: date,
        );

  DailyMealCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    int Function(DailyMealCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyMealCountProvider._internal(
        (ref) => create(ref as DailyMealCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _DailyMealCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyMealCountProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyMealCountRef on AutoDisposeProviderRef<int> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _DailyMealCountProviderElement extends AutoDisposeProviderElement<int>
    with DailyMealCountRef {
  _DailyMealCountProviderElement(super.provider);

  @override
  DateTime get date => (origin as DailyMealCountProvider).date;
}

String _$mealsNotifierHash() => r'f673a5c965f5d7ef7492b5d4ac6ba0851ec867d8';

abstract class _$MealsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  late final DateTime date;

  FutureOr<List<Map<String, dynamic>>> build(
    DateTime date,
  );
}

/// Meals state for a specific date
///
/// Copied from [MealsNotifier].
@ProviderFor(MealsNotifier)
const mealsNotifierProvider = MealsNotifierFamily();

/// Meals state for a specific date
///
/// Copied from [MealsNotifier].
class MealsNotifierFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Meals state for a specific date
  ///
  /// Copied from [MealsNotifier].
  const MealsNotifierFamily();

  /// Meals state for a specific date
  ///
  /// Copied from [MealsNotifier].
  MealsNotifierProvider call(
    DateTime date,
  ) {
    return MealsNotifierProvider(
      date,
    );
  }

  @override
  MealsNotifierProvider getProviderOverride(
    covariant MealsNotifierProvider provider,
  ) {
    return call(
      provider.date,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mealsNotifierProvider';
}

/// Meals state for a specific date
///
/// Copied from [MealsNotifier].
class MealsNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MealsNotifier, List<Map<String, dynamic>>> {
  /// Meals state for a specific date
  ///
  /// Copied from [MealsNotifier].
  MealsNotifierProvider(
    DateTime date,
  ) : this._internal(
          () => MealsNotifier()..date = date,
          from: mealsNotifierProvider,
          name: r'mealsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mealsNotifierHash,
          dependencies: MealsNotifierFamily._dependencies,
          allTransitiveDependencies:
              MealsNotifierFamily._allTransitiveDependencies,
          date: date,
        );

  MealsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  FutureOr<List<Map<String, dynamic>>> runNotifierBuild(
    covariant MealsNotifier notifier,
  ) {
    return notifier.build(
      date,
    );
  }

  @override
  Override overrideWith(MealsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MealsNotifierProvider._internal(
        () => create()..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MealsNotifier,
      List<Map<String, dynamic>>> createElement() {
    return _MealsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealsNotifierProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MealsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _MealsNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MealsNotifier,
        List<Map<String, dynamic>>> with MealsNotifierRef {
  _MealsNotifierProviderElement(super.provider);

  @override
  DateTime get date => (origin as MealsNotifierProvider).date;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
