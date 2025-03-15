import 'package:ddai_community/chat/model/chat_model.dart';
import 'package:ddai_community/chat/repository/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddChatParams {
  final String content;
  final String userName;

  AddChatParams({
    required this.content,
    required this.userName,
  });
}

// 채팅 목록 GET
final getChatListProvider =
    StreamProvider.autoDispose<List<ChatModel>>((ref) async* {
  final result = ChatRepository.getChatList();

  yield* result;
});

// 채팅 ADD
final addChatProvider =
    FutureProvider.family<void, AddChatParams>((ref, params) async {
  await ChatRepository.addChat(
    content: params.content,
    userName: params.userName,
  );
});
