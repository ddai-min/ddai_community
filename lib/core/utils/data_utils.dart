/// 데이터 가공 관련 유틸.
class DataUtils {
  /// 익명 사용자에게 보여줄 표시 이름을 생성한다. (예: `익명a1b2c3`)
  ///
  /// uid 앞 6자리를 사용하므로 사용자마다 대체로 구분된다.
  static String setAnonymousName({
    required String uid,
  }) {
    return '익명${uid.substring(0, 6)}';
  }

  /// 목록에 보여줄 작성 시각 문자열을 만든다.
  /// (예: `방금 전` · `3분 전` · `5시간 전` · `2026.09.01`)
  ///
  /// 최근 글은 상대 시각으로, 한 주가 지난 글은 날짜로 보여준다.
  /// 오래된 글까지 "312일 전" 으로 적으면 오히려 읽기 어렵다.
  static String formatRelativeDate(DateTime date) {
    final local = date.toLocal();
    final diff = DateTime.now().difference(local);

    // 기기 시계가 서버보다 느리면 음수가 나온다. 미래처럼 보이지 않게 막는다.
    if (diff.isNegative || diff.inMinutes < 1) {
      return '방금 전';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    }

    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');

    return '${local.year}.$month.$day';
  }
}
