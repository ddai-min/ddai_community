import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/chat/model/chat_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/main.dart';

class ChatRepository extends PaginationRepository<ChatModel> {
  ChatRepository()
      : super(
          collectionPath: CollectionPath.chat,
          fromJson: (data) => ChatModel.fromJson(data),
        );

  static Future<void> addChat({
    required String content,
    required String userName,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final chatRef = firestore.collection('chat').doc();

      Map<String, dynamic> chatData = ChatModel(
        id: chatRef.id,
        content: content,
        userName: userName,
        date: DateTime.now(),
      ).toJson();

      await chatRef.set(chatData);
    } catch (error) {
      logger.e(error);
    }
  }
}
