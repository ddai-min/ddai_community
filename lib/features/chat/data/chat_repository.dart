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

  /// 채팅 메시지를 삭제한다. 성공 여부를 bool 로 반환한다.
  ///
  /// 지워진 행을 되받아 실제로 지워졌는지 확인한다. RLS(`chat_delete_own`)가 막으면
  /// 오류 없이 0행이 지워지므로, 이 확인이 없으면 실패를 성공으로 보고하게 된다.
  ///
  /// 화면에서 말풍선이 걷히는 것은 **실시간 스트림이 담당한다.** 전송 때처럼 미리
  /// 지우지는 않는다 — 삭제는 사용자가 그 사이 할 일이 없어서 왕복이 드러나지 않는다.
  static Future<bool> deleteChat({
    required String searchId,
  }) async {
    try {
      final deletedRows = await supabase
          .from('chat')
          .delete()
          .eq('id', searchId)
          .select('id');

      return deletedRows.isNotEmpty;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }
}
