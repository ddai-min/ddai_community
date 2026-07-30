// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 신고. 결과로 성공 여부(bool)를 반환한다.

@ProviderFor(report)
final reportProvider = ReportFamily._();

/// 신고. 결과로 성공 여부(bool)를 반환한다.

final class ReportProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 신고. 결과로 성공 여부(bool)를 반환한다.
  ReportProvider._({
    required ReportFamily super.from,
    required ReportParams super.argument,
  }) : super(
         retry: null,
         name: r'reportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reportHash();

  @override
  String toString() {
    return r'reportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as ReportParams;
    return report(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reportHash() => r'b316032452ea4d29d7cfc823276fbbae39984e02';

/// 신고. 결과로 성공 여부(bool)를 반환한다.

final class ReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, ReportParams> {
  ReportFamily._()
    : super(
        retry: null,
        name: r'reportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 신고. 결과로 성공 여부(bool)를 반환한다.

  ReportProvider call(ReportParams params) =>
      ReportProvider._(argument: params, from: this);

  @override
  String toString() => r'reportProvider';
}
