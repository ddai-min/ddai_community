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
}
