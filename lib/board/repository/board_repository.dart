import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/board/model/board_parameter.dart';
import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/main.dart';

class BoardRepository extends PaginationRepository<BoardModel> {
  BoardRepository()
      : super(
          collectionPath: CollectionPath.board,
          fromJson: (data) => BoardModel.fromJson(data),
        );

  static Future<BoardModel?> getBoard({
    required String searchId,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final boardSnapshot =
          await firestore.collection('board').doc(searchId).get();

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
