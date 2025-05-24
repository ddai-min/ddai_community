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
