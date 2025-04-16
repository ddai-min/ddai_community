import 'package:ddai_community/user/repository/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportParams {
  final String reporterUserName;
  final String reporterUserUid;
  final String reportedUserName;
  final String reportedUserUid;
  final String reportReason;
  final String reportContentId;

  ReportParams({
    required this.reporterUserName,
    required this.reporterUserUid,
    required this.reportedUserName,
    required this.reportedUserUid,
    required this.reportReason,
    required this.reportContentId,
  });
}

// 신고
final reportProvider =
    FutureProvider.family.autoDispose<bool, ReportParams>((ref, params) async {
  final result = await ReportRepository.report(
    reporterUserName: params.reporterUserName,
    reporterUserUid: params.reporterUserUid,
    reportedUserName: params.reportedUserName,
    reportedUserUid: params.reportedUserUid,
    reportReason: params.reportReason,
    reportContentId: params.reportContentId,
  );

  return result;
});
