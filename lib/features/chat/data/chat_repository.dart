import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/chat/domain/chat_model.dart';
import 'package:ddai_community/features/chat/domain/chat_parameter.dart';

/// 채팅(`chat` 테이블) 관련 Supabase 연산.
///
/// 목록은 [PaginationRepository.streamData] 로 실시간 구독한다.
/// (Realtime 이 켜져 있어야 한다 — `alter publication supabase_realtime add table public.chat`)
class ChatRepository extends PaginationRepository<ChatModel> {
  ChatRepository()
      : super(
          table: TablePath.chat,
          fromJson: (data) => ChatModel.fromJson(data),
        );

  /// 채팅 메시지를 전송한다.
  ///
  /// 실시간 스트림으로 목록이 갱신되므로 별도 반환값은 없다.
  static Future<void> addChat({
    required AddChatParams addChatParams,
  }) async {
    try {
      await supabase.from('chat').insert({
        'content': addChatParams.content,
        'user_name': addChatParams.userName,
        'user_uid': addChatParams.userUid,
      });
    } catch (error) {
      logger.e(error);
    }
  }
}
