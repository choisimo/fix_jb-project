// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportDetailControllerHash() =>
    r'cad49f205c00f9efc9edf8b500675ebdf0048899';

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

abstract class _$ReportDetailController
    extends BuildlessAutoDisposeNotifier<ReportDetailState> {
  late final String reportId;

  ReportDetailState build(
    String reportId,
  );
}

/// See also [ReportDetailController].
@ProviderFor(ReportDetailController)
const reportDetailControllerProvider = ReportDetailControllerFamily();

/// See also [ReportDetailController].
class ReportDetailControllerFamily extends Family<ReportDetailState> {
  /// See also [ReportDetailController].
  const ReportDetailControllerFamily();

  /// See also [ReportDetailController].
  ReportDetailControllerProvider call(
    String reportId,
  ) {
    return ReportDetailControllerProvider(
      reportId,
    );
  }

  @override
  ReportDetailControllerProvider getProviderOverride(
    covariant ReportDetailControllerProvider provider,
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
  String? get name => r'reportDetailControllerProvider';
}

/// See also [ReportDetailController].
class ReportDetailControllerProvider extends AutoDisposeNotifierProviderImpl<
    ReportDetailController, ReportDetailState> {
  /// See also [ReportDetailController].
  ReportDetailControllerProvider(
    String reportId,
  ) : this._internal(
          () => ReportDetailController()..reportId = reportId,
          from: reportDetailControllerProvider,
          name: r'reportDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportDetailControllerHash,
          dependencies: ReportDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              ReportDetailControllerFamily._allTransitiveDependencies,
          reportId: reportId,
        );

  ReportDetailControllerProvider._internal(
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
  ReportDetailState runNotifierBuild(
    covariant ReportDetailController notifier,
  ) {
    return notifier.build(
      reportId,
    );
  }

  @override
  Override overrideWith(ReportDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReportDetailControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<ReportDetailController, ReportDetailState>
      createElement() {
    return _ReportDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportDetailControllerProvider &&
        other.reportId == reportId;
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
mixin ReportDetailControllerRef
    on AutoDisposeNotifierProviderRef<ReportDetailState> {
  /// The parameter `reportId` of this provider.
  String get reportId;
}

class _ReportDetailControllerProviderElement
    extends AutoDisposeNotifierProviderElement<ReportDetailController,
        ReportDetailState> with ReportDetailControllerRef {
  _ReportDetailControllerProviderElement(super.provider);

  @override
  String get reportId => (origin as ReportDetailControllerProvider).reportId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
