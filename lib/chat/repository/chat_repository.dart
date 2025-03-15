import 'package:ddai_community/chat/model/chat_model.dart';
import 'package:ddai_community/main.dart';

class ChatRepository {
  static Stream<List<ChatModel>> getChatList() {
    return firestore
        .collection('chat')
        .orderBy(
          'date',
          descending: false,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatModel.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  static Future<void> addChat({
    required String content,
    required String userName,
  }) async {
    try {
      final chatRef = firestore.collection('chat').doc();

      Map<String, dynamic> chatData = ChatModel(
        id: chatRef.id,
        content: content,
        userName: userName,
        date: DateTime.now(),
      ).toJson();

      await chatRef.set(chatData);
    } catch (e) {
      logger.e(e);
    }
  }
}
