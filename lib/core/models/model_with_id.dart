/// 목록으로 다루는 모든 모델이 구현하는 공통 계약.
///
/// [PaginationRepository]/[PaginationMixin] 이 테이블 종류와 무관하게
/// 동일한 로직으로 목록을 다룰 수 있도록, 모든 모델은 행 id 를 노출한다.
abstract class ModelWithId {
  /// 행의 기본키(uuid).
  final String id;

  ModelWithId({
    required this.id,
  });
}
