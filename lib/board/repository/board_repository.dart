import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/model/board_model.dart';
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
    BoardModel? boardModel;
    List<CommentModel>? commentList;

    try {
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

      commentList = commentSnapshot.docs
          .map((e) => CommentModel.fromJson(e.data()))
          .toList();

      Timestamp timestamp = boardSnapshot['date'];
      DateTime date = timestamp.toDate();

      boardModel = BoardModel(
        id: boardSnapshot['id'],
        title: boardSnapshot['title'],
        content: boardSnapshot['content'],
        userName: boardSnapshot['userName'],
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
    required String title,
    required String content,
    required String userName,
  }) async {
    try {
      final boardRef = firestore.collection('board').doc();

      Map<String, dynamic> boardData = BoardModel(
        id: boardRef.id,
        title: title,
        content: content,
        userName: userName,
        date: DateTime.now(),
      ).toJson();

      await boardRef.set(boardData);

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }
}
