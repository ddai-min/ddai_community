/// 게시글 하나의 좋아요 상태.
///
/// JSON 직렬화 대상이 아니다. `board_like` 행을 세어 만든 화면용 값이라
/// 테이블 구조와 1:1로 대응하지 않는다.
class BoardLikeModel {
  final int count;

  /// 내가 누른 좋아요가 있는지.
  final bool isLiked;

  const BoardLikeModel({
    required this.count,
    required this.isLiked,
  });
}
