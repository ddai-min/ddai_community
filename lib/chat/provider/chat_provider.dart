import 'package:ddai_community/chat/model/chat_model.dart';
import 'package:ddai_community/chat/model/chat_parameter.dart';
import 'package:ddai_community/chat/repository/chat_repository.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/provider/pagination_provider.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [ChatRepository] 인스턴스 제공.
final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(),
);

/// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
class ChatListNotifier extends PaginationNotifier<ChatModel> {
  @override
  PaginationRepository<ChatModel> readRepository() =>
      ref.watch(chatRepositoryProvider);

  @override
  CollectionPath get collectionPath => CollectionPath.chat;

  @override
  bool get isUsingStream => true;
}

/// 채팅 목록 상태. 실시간 스트림으로 동기화된다. (isUsingStream: true)
final getChatListProvider =
    NotifierProvider.autoDispose<ChatListNotifier, PaginationModel<ChatModel>>(
  ChatListNotifier.new,
);

/// 채팅 메시지 전송.
final addChatProvider =
    FutureProvider.family<void, AddChatParams>((ref, params) async {
  await ChatRepository.addChat(
    addChatParams: params,
  );
});
