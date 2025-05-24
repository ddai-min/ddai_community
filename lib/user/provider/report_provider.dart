import 'package:ddai_community/user/model/report_parameter.dart';
import 'package:ddai_community/user/repository/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 신고
final reportProvider =
    FutureProvider.family.autoDispose<bool, ReportParams>((ref, params) async {
  final result = await ReportRepository.report(
    reportParams: params,
  );

  return result;
});
