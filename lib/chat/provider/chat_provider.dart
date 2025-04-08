import 'package:ddai_community/chat/model/chat_model.dart';
import 'package:ddai_community/chat/repository/chat_repository.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/provider/pagination_provider.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddChatParams {
  final String content;
  final String userName;
  final String userEmail;

  AddChatParams({
    required this.content,
    required this.userName,
    required this.userEmail,
  });
}

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(),
);

// 채팅 목록 GET
final getChatListProvider = StateNotifierProvider.autoDispose<
    PaginationProvider<ChatModel>, PaginationModel<ChatModel>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);

  return PaginationProvider<ChatModel>(
    paginationRepository: repository,
    collectionPath: CollectionPath.chat,
    isUsingStream: true,
  );
});

// 채팅 ADD
final addChatProvider =
    FutureProvider.family<void, AddChatParams>((ref, params) async {
  await ChatRepository.addChat(
    content: params.content,
    userName: params.userName,
    userEmail: params.userEmail,
  );
});
