import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/main.dart';

class CommentRepository extends PaginationRepository<CommentModel> {
  CommentRepository()
      : super(
          collectionPath: CollectionPath.comment,
          fromJson: (data) => CommentModel.fromJson(data),
        );

  static Future<bool> addComment({
    required String searchId,
    required String userName,
    required String userUid,
    required String content,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final commentRef = firestore
          .collection('board')
          .doc(searchId)
          .collection('comment')
          .doc();

      Map<String, dynamic> commentData = CommentModel(
        id: commentRef.id,
        userName: userName,
        userUid: userUid,
        content: content,
        date: DateTime.now(),
      ).toJson();

      await commentRef.set(commentData);

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }
}
