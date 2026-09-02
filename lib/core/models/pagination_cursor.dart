/// keyset 페이지네이션의 커서.
///
/// Firestore 의 `DocumentSnapshot` 커서를 대신한다. Postgres 에는 스냅샷 개념이 없어
/// **정렬 키의 값 자체**를 커서로 들고 다닌다. 정렬은 `created_at desc, id desc` 이므로
/// 두 값을 함께 보관해야 같은 시각에 생성된 행에서 경계가 흔들리지 않는다.
///
/// offset(`range`) 방식이 아닌 이유: 게시글·채팅처럼 쓰기가 잦으면 페이지를 넘기는 사이
/// 앞쪽에 행이 끼어들어 항목이 밀리거나 중복된다.
class PaginationCursor {
  /// 직전 페이지 마지막 행의 `created_at`.
  final DateTime createdAt;

  /// 직전 페이지 마지막 행의 `id`. (`created_at` 동률일 때의 타이브레이커)
  final String id;

  const PaginationCursor({
    required this.createdAt,
    required this.id,
  });
}
