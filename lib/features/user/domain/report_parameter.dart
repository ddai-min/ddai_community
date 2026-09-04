/// 신고 대상 콘텐츠의 종류.
///
/// [value] 는 `report.report_content_type` 의 CHECK 제약과 **같은 문자열**이어야 한다.
/// 값을 늘리려면 DB 제약도 함께 고친다.
enum ReportContentType {
  board('board', '게시글'),
  comment('comment', '댓글'),
  chat('chat', '채팅');

  final String value;

  /// 안내 문구에 쓰는 한글 이름.
  final String label;

  const ReportContentType(
    this.value,
    this.label,
  );
}

/// 신고 요청 파라미터.
class ReportParams {
  final String reporterUserName;
  final String reporterUserUid;
  final String reportedUserName;
  final String reportedUserUid;
  final String reportReason;

  /// 신고 대상 행의 id. 종류는 [reportContentType] 이 알려준다.
  final String reportContentId;

  /// 게시글·댓글·채팅 중 무엇을 신고한 것인지.
  ///
  /// 이 값이 없으면 운영자가 id 만 보고 어느 테이블을 봐야 할지 알 수 없다.
  final ReportContentType reportContentType;

  ReportParams({
    required this.reporterUserName,
    required this.reporterUserUid,
    required this.reportedUserName,
    required this.reportedUserUid,
    required this.reportReason,
    required this.reportContentId,
    required this.reportContentType,
  });
}
