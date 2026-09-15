/// 댓글 작성 요청 파라미터.
class AddCommentParams {
  /// 댓글을 달 대상 게시글 id.
  final String searchId;
  final String userName;
  final String userUid;
  final String content;

  AddCommentParams({
    required this.searchId,
    required this.userName,
    required this.userUid,
    required this.content,
  });
}

/// 댓글 수정 요청 파라미터.
///
/// 고칠 수 있는 것은 내용뿐이다. 작성자 이름은 DB 가 컬럼 단위 grant 로 막는다.
class UpdateCommentParams {
  /// 수정할 댓글 id.
  final String searchId;

  final String content;

  UpdateCommentParams({
    required this.searchId,
    required this.content,
  });
}
