import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/board/domain/comment_model.dart';
import 'package:ddai_community/features/board/domain/comment_parameter.dart';

/// 댓글(`comment` 테이블) 관련 Supabase 연산.
///
/// Firestore 의 `board/{boardId}/comment` 하위 컬렉션을 `board_id` FK 로 대체했다.
/// 목록 페이지네이션은 [PaginationRepository] 가 `parentColumn` 으로 범위를 좁혀 처리한다.
class CommentRepository extends PaginationRepository<CommentModel> {
  CommentRepository()
    : super(
        table: TablePath.comment,
        parentColumn: 'board_id',
        fromJson: (data) => CommentModel.fromJson(data),
      );

  /// 특정 게시글에 댓글을 추가한다. 성공 여부를 bool 로 반환한다.
  static Future<bool> addComment({
    required AddCommentParams addCommentParams,
  }) async {
    try {
      await supabase.from('comment').insert({
        'board_id': addCommentParams.searchId,
        'content': addCommentParams.content,
        'user_name': addCommentParams.userName,
        'user_uid': addCommentParams.userUid,
      });

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 댓글을 삭제한다. 성공 여부를 bool 로 반환한다.
  ///
  /// 지워진 행을 되받아 실제로 지워졌는지 확인한다. RLS(`comment_delete_own`)가 막으면
  /// 오류 없이 0행이 지워지므로, 이 확인이 없으면 실패를 성공으로 보고하게 된다.
  static Future<bool> deleteComment({
    required String searchId,
  }) async {
    try {
      final deletedRows = await supabase
          .from('comment')
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
