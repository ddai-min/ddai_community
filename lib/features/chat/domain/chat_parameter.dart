/// 채팅 메시지 전송 요청 파라미터.
class AddChatParams {
  final String content;
  final String userName;
  final String userUid;

  AddChatParams({
    required this.content,
    required this.userName,
    required this.userUid,
  });
}
