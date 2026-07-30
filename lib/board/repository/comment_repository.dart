import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/board/model/comment_parameter.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/main.dart';

/// 댓글(`board/{boardId}/comment` 하위 컬렉션) 관련 Firestore 연산.
///
/// 목록 페이지네이션은 [PaginationRepository] 가 처리한다.
class CommentRepository extends PaginationRepository<CommentModel> {
  CommentRepository()
      : super(
          collectionPath: CollectionPath.comment,
          fromJson: (data) => CommentModel.fromJson(data),
        );

  /// 특정 게시글에 댓글을 추가한다. 성공 여부를 bool 로 반환한다.
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
