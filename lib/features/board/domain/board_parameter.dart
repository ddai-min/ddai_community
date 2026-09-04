/// 게시글 작성 요청 파라미터.
/// 게시글 수정 요청 파라미터.
///
/// 작성자 정보는 담지 않는다. 수정으로 글쓴이가 바뀌면 안 되고,
/// DB 도 `title`·`content` 컬럼에만 UPDATE 를 허용한다.
class UpdateBoardParams {
  final String searchId;
  final String title;
  final String content;

  UpdateBoardParams({
    required this.searchId,
    required this.title,
    required this.content,
  });
}

class AddBoardParams {
  final String title;
  final String content;
  final String userName;
  final String userUid;

  AddBoardParams({
    required this.title,
    required this.content,
    required this.userName,
    required this.userUid,
  });
}
