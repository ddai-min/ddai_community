import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/board/model/board_parameter.dart';
import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/common/util/logger.dart';

/// 게시글(`board` 컬렉션) 관련 Firestore 연산.
///
/// 목록 페이지네이션은 [PaginationRepository] 를 상속해 처리하고,
/// 단건 조회·생성·삭제는 정적 메서드로 제공한다.
class BoardRepository extends PaginationRepository<BoardModel> {
  BoardRepository()
      : super(
          collectionPath: CollectionPath.board,
          fromJson: (data) => BoardModel.fromJson(data),
        );

  /// 게시글 1건과 그 댓글 목록(오래된 순)을 함께 조회한다.
  ///
  /// 조회에 실패하면 null 을 반환한다.
  static Future<BoardModel?> getBoard({
    required String searchId,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final boardSnapshot =
          await firestore.collection('board').doc(searchId).get();

      // 댓글은 작성 순서대로 보여주기 위해 오래된 순(오름차순)으로 조회한다.
      final commentSnapshot = await firestore
          .collection('board')
          .doc(searchId)
          .collection('comment')
          .orderBy(
            'date',
            descending: false,
          )
          .get();

      final commentList = commentSnapshot.docs
          .map((e) => CommentModel.fromJson(e.data()))
          .toList();

      Timestamp timestamp = boardSnapshot['date'];
      DateTime date = timestamp.toDate();

      final boardModel = BoardModel(
        id: boardSnapshot['id'],
        title: boardSnapshot['title'],
        content: boardSnapshot['content'],
        userName: boardSnapshot['userName'],
        userUid: boardSnapshot['userUid'],
        date: date,
        commentList: commentList,
      );

      return boardModel;
    } catch (error) {
      logger.e(error);

      return null;
    }
  }

  /// 새 게시글을 생성한다. 문서 id 는 Firestore 가 자동 생성한다.
  ///
  /// 성공 여부를 bool 로 반환한다.
  static Future<bool> addBoard({
    required AddBoardParams addBoardParams,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final boardRef = firestore.collection('board').doc();

      Map<String, dynamic> boardData = BoardModel(
        id: boardRef.id,
        title: addBoardParams.title,
        content: addBoardParams.content,
        userName: addBoardParams.userName,
        userUid: addBoardParams.userUid,
        date: DateTime.now(),
      ).toJson();

      await boardRef.set(boardData);

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 게시글을 삭제한다. 성공 여부를 bool 로 반환한다.
  static Future<bool> deleteBoard({
    required String searchId,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('board').doc(searchId).delete();

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }
}
