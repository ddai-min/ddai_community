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
