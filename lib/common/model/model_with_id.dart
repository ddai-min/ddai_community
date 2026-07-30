/// 모든 Firestore 모델이 구현하는 공통 계약.
///
/// [PaginationRepository]/[PaginationProvider] 가 문서 종류와 무관하게
/// 동일한 로직으로 목록을 다룰 수 있도록, 모든 모델은 문서 id 를 노출한다.
abstract class ModelWithId {
  /// Firestore 문서 id.
  final String id;

  ModelWithId({
    required this.id,
  });
}
