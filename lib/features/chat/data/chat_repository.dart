import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/chat/domain/chat_model.dart';
import 'package:ddai_community/features/chat/domain/chat_parameter.dart';

/// 채팅(`chat` 컬렉션) 관련 Firestore 연산.
///
/// 목록은 [PaginationRepository.streamData] 로 실시간 구독한다.
class ChatRepository extends PaginationRepository<ChatModel> {
  ChatRepository()
      : super(
          collectionPath: CollectionPath.chat,
          fromJson: (data) => ChatModel.fromJson(data),
        );

  /// 채팅 메시지를 전송한다. (문서 생성)
  ///
  /// 실시간 스트림으로 목록이 갱신되므로 별도 반환값은 없다.
  static Future<void> addChat({
    required AddChatParams addChatParams,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final chatRef = firestore.collection('chat').doc();

      Map<String, dynamic> chatData = ChatModel(
        id: chatRef.id,
        content: addChatParams.content,
        userName: addChatParams.userName,
        userUid: addChatParams.userUid,
        date: DateTime.now(),
      ).toJson();

      await chatRef.set(chatData);
    } catch (error) {
      logger.e(error);
    }
  }
}
