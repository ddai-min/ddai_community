import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/board/domain/board_model.dart';
import 'package:ddai_community/features/board/domain/board_parameter.dart';

/// 게시글(`board` 테이블) 관련 Supabase 연산.
///
/// 목록 페이지네이션은 [PaginationRepository] 를 상속해 처리하고,
/// 단건 조회·생성·삭제는 정적 메서드로 제공한다.
class BoardRepository extends PaginationRepository<BoardModel> {
  BoardRepository()
    : super(
        table: TablePath.board,
        fromJson: (data) => BoardModel.fromJson(data),
      );

  /// 게시글 1건과 그 댓글 목록(오래된 순)을 함께 조회한다.
  ///
  /// FK 임베딩(`comment(*)`)으로 **한 번에** 가져온다. (Firestore 때는 두 번 조회했다)
  /// 게시글이 없거나 차단한 유저의 글이면 RLS 로 0행이 되어 `single()` 이 예외를 던지고,
  /// 그 경우 null 을 반환한다.
  static Future<BoardModel?> getBoard({
    required String searchId,
  }) async {
    try {
      final row = await supabase
          .from('board')
          .select('*, comment(*)')
          .eq('id', searchId)
          // 댓글은 작성 순서대로 보여주기 위해 오래된 순(오름차순)으로 정렬한다.
          .order('created_at', referencedTable: 'comment', ascending: true)
          .single();

      return BoardModel.fromJson(row);
    } catch (error) {
      logger.e(error);

      return null;
    }
  }

  /// 새 게시글을 생성한다. `id` 와 `created_at` 은 DB 기본값에 맡긴다.
  ///
  /// 성공 여부를 bool 로 반환한다.
  static Future<bool> addBoard({
    required AddBoardParams addBoardParams,
  }) async {
    try {
      await supabase.from('board').insert({
        'title': addBoardParams.title,
        'content': addBoardParams.content,
        'user_name': addBoardParams.userName,
        'user_uid': addBoardParams.userUid,
      });

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 게시글을 삭제한다. 댓글은 FK CASCADE 로 함께 지워진다.
  ///
  /// 삭제된 행을 되받아 실제로 지워졌는지 확인한다. RLS(`board_delete_own`)가 막으면
  /// 오류 없이 0행이 지워지므로, 이 확인이 없으면 실패를 성공으로 보고하게 된다.
  static Future<bool> deleteBoard({
    required String searchId,
  }) async {
    try {
      final deletedRows = await supabase
          .from('board')
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
