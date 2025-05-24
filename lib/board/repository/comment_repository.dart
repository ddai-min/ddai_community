import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/board/model/comment_parameter.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/main.dart';

class CommentRepository extends PaginationRepository<CommentModel> {
  CommentRepository()
      : super(
          collectionPath: CollectionPath.comment,
          fromJson: (data) => CommentModel.fromJson(data),
        );

  static Future<bool> addComment({
    required AddCommentParams addCommentParams,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final commentRef = firestore
          .collection('board')
          .doc(addCommentParams.searchId)
          .collection('comment')
          .doc();

      Map<String, dynamic> commentData = CommentModel(
        id: commentRef.id,
        userName: addCommentParams.userName,
        userUid: addCommentParams.userUid,
        content: addCommentParams.content,
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
