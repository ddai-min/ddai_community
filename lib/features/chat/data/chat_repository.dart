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

  /// 채팅 메시지를 전송하고 **생성된 행**을 돌려준다. (실패 시 `null`)
  ///
  /// 실시간 스트림이 이 행을 다시 실어 보내주기까지 평균 450ms 가 걸린다.
  /// 그동안 화면에 띄워 둔 임시 말풍선을 진짜 행으로 바꿔치기하려면 실제 `id` 가
  /// 필요하므로 `.select()` 로 되받는다. ([ChatList.sendChat] 참고)
  static Future<ChatModel?> addChat({
    required AddChatParams addChatParams,
  }) async {
    try {
      final row = await supabase
          .from('chat')
          .insert({
            'content': addChatParams.content,
            'user_name': addChatParams.userName,
            'user_uid': addChatParams.userUid,
          })
          .select()
          .single();

      return ChatModel.fromJson(row);
    } catch (error) {
      logger.e(error);

      return null;
    }
  }
}
