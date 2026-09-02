import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/providers/pagination_provider.dart';
import 'package:ddai_community/features/chat/data/chat_repository.dart';
import 'package:ddai_community/features/chat/domain/chat_model.dart';
import 'package:ddai_community/features/chat/domain/chat_parameter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_provider.g.dart';

/// [ChatRepository] 인스턴스 제공.
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) => ChatRepository();

/// 채팅 목록 Notifier. 실시간 스트림으로 동기화된다.
@riverpod
class ChatList extends _$ChatList with PaginationMixin<ChatModel> {
  @override
  PaginationModel<ChatModel> build() {
    subscribeStream();
    return initialState();
  }

  @override
  PaginationRepository<ChatModel> get paginationRepository =>
      ref.read(chatRepositoryProvider);
}

/// 채팅 메시지 전송.
@riverpod
Future<void> addChat(Ref ref, AddChatParams params) =>
    ChatRepository.addChat(addChatParams: params);
