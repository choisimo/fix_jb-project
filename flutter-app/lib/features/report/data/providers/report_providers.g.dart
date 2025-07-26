// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportServiceHash() => r'd5186209f35ae9291eb7b63f75b554f9285c918c';

/// 리포트 서비스 Provider
///
/// Copied from [reportService].
@ProviderFor(reportService)
final reportServiceProvider = AutoDisposeProvider<ReportService>.internal(
  reportService,
  name: r'reportServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportServiceRef = AutoDisposeProviderRef<ReportService>;
String _$reportRepositoryHash() => r'b83f0fadf248087dd1452d18b06aa5282fd67241';

/// 리포트 리포지토리 Provider
///
/// Copied from [reportRepository].
@ProviderFor(reportRepository)
final reportRepositoryProvider = AutoDisposeProvider<ReportRepository>.internal(
  reportRepository,
  name: r'reportRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportRepositoryRef = AutoDisposeProviderRef<ReportRepository>;
String _$reportListHash() => r'9374f40e215184706f9e398a3f8925f5bb033b16';

/// 리포트 목록 Provider
///
/// Copied from [ReportList].
@ProviderFor(ReportList)
final reportListProvider =
    AutoDisposeAsyncNotifierProvider<ReportList, List<Report>>.internal(
  ReportList.new,
  name: r'reportListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$reportListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportList = AutoDisposeAsyncNotifier<List<Report>>;
String _$myReportsHash() => r'2a54b44479621a5bc2f2f1e99737be27cb1d3a02';

/// 내 리포트 목록 Provider
///
/// Copied from [MyReports].
@ProviderFor(MyReports)
final myReportsProvider =
    AutoDisposeAsyncNotifierProvider<MyReports, List<Report>>.internal(
  MyReports.new,
  name: r'myReportsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myReportsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyReports = AutoDisposeAsyncNotifier<List<Report>>;
String _$reportDetailHash() => r'76712ba760e372b8af663c3eff7def687541e55a';

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

abstract class _$ReportDetail
    extends BuildlessAutoDisposeAsyncNotifier<Report?> {
  late final String reportId;

  FutureOr<Report?> build(
    String reportId,
  );
}

/// 리포트 상세 Provider
///
/// Copied from [ReportDetail].
@ProviderFor(ReportDetail)
const reportDetailProvider = ReportDetailFamily();

/// 리포트 상세 Provider
///
/// Copied from [ReportDetail].
class ReportDetailFamily extends Family<AsyncValue<Report?>> {
  /// 리포트 상세 Provider
  ///
  /// Copied from [ReportDetail].
  const ReportDetailFamily();

  /// 리포트 상세 Provider
  ///
  /// Copied from [ReportDetail].
  ReportDetailProvider call(
    String reportId,
  ) {
    return ReportDetailProvider(
      reportId,
    );
  }

  @override
  ReportDetailProvider getProviderOverride(
    covariant ReportDetailProvider provider,
  ) {
    return call(
      provider.reportId,
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
  String? get name => r'reportDetailProvider';
}

/// 리포트 상세 Provider
///
/// Copied from [ReportDetail].
class ReportDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ReportDetail, Report?> {
  /// 리포트 상세 Provider
  ///
  /// Copied from [ReportDetail].
  ReportDetailProvider(
    String reportId,
  ) : this._internal(
          () => ReportDetail()..reportId = reportId,
          from: reportDetailProvider,
          name: r'reportDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportDetailHash,
          dependencies: ReportDetailFamily._dependencies,
          allTransitiveDependencies:
              ReportDetailFamily._allTransitiveDependencies,
          reportId: reportId,
        );

  ReportDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reportId,
  }) : super.internal();

  final String reportId;

  @override
  FutureOr<Report?> runNotifierBuild(
    covariant ReportDetail notifier,
  ) {
    return notifier.build(
      reportId,
    );
  }

  @override
  Override overrideWith(ReportDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReportDetailProvider._internal(
        () => create()..reportId = reportId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reportId: reportId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ReportDetail, Report?>
      createElement() {
    return _ReportDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportDetailProvider && other.reportId == reportId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reportId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReportDetailRef on AutoDisposeAsyncNotifierProviderRef<Report?> {
  /// The parameter `reportId` of this provider.
  String get reportId;
}

class _ReportDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ReportDetail, Report?>
    with ReportDetailRef {
  _ReportDetailProviderElement(super.provider);

  @override
  String get reportId => (origin as ReportDetailProvider).reportId;
}

String _$reportFilterHash() => r'cf51d3335a8483b156befba802837c578fe3dab9';

/// 리포트 필터 Provider
///
/// Copied from [ReportFilter].
@ProviderFor(ReportFilter)
final reportFilterProvider =
    AutoDisposeNotifierProvider<ReportFilter, ReportFilterData>.internal(
  ReportFilter.new,
  name: r'reportFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$reportFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportFilter = AutoDisposeNotifier<ReportFilterData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
