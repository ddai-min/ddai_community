import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/board/domain/board_like_model.dart';
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
        // 별칭을 붙여야 상세의 `comment(*)` 와 키가 겹치지 않는다.
        // 조회수는 `board.view_count` 컬럼이라 `*` 에 이미 들어 있다.
        selectColumns:
            '*, comment_count:comment(count), like_count:board_like(count)',
        searchColumns: const ['title', 'content'],
      );

  /// 게시글 1건과 그 댓글 목록(오래된 순)을 함께 조회한다.
  ///
  /// FK 임베딩(`comment(*)`)으로 **한 번에** 가져온다. (Firestore 때는 두 번 조회했다)
  /// 게시글이 없거나 차단한 유저의 글이면 RLS 로 0행이 되어 `single()` 이 예외를 던지고,
  /// 그 경우 null 을 반환한다.
  ///
  /// **읽기 전에 [viewBoard] 로 조회를 먼저 기록한다.** 순서를 뒤집으면 이 글을 처음
  /// 여는 사람에게 자기를 뺀 수("조회 0")가 보인다. 중복은 서버가 무시하므로
  /// 왕복 한 번(약 30ms)이 더해질 뿐이다.
  /// 게시글 수정 화면도 이 메서드로 원글을 읽어 조회가 함께 기록되는데, 내 글이고
  /// 한 번만 세므로 그냥 읽었을 때와 결과가 같다.
  static Future<BoardModel?> getBoard({
    required String searchId,
  }) async {
    try {
      await viewBoard(searchId: searchId);

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

  /// 게시글의 좋아요 수와 내가 눌렀는지를 한 번에 조회한다.
  ///
  /// 행을 세어 개수를 구한다. 집계(`count`)로 따로 물으면 "내가 눌렀는지" 를 알기 위해
  /// 한 번 더 다녀와야 해서, 요청을 하나로 줄이는 쪽을 택했다.
  /// 글 하나에 좋아요가 수천 개씩 붙는 규모가 되면 집계로 바꾼다.
  static Future<BoardLikeModel> getBoardLike({
    required String searchId,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      final rows = await supabase
          .from('board_like')
          .select('user_uid')
          .eq('board_id', searchId);

      return BoardLikeModel(
        count: rows.length,
        isLiked: userId != null && rows.any((row) => row['user_uid'] == userId),
      );
    } catch (error) {
      logger.e(error);

      return const BoardLikeModel(count: 0, isLiked: false);
    }
  }

  /// 좋아요를 누른다. 성공 여부를 bool 로 반환한다.
  ///
  /// **`ignoreDuplicates` 를 빼지 말 것.** 기본 upsert 는 `ON CONFLICT DO UPDATE` 로
  /// 나가는데 `board_like` 에는 UPDATE 정책이 없어서, 연타로 같은 행이 두 번 들어오면
  /// 403 으로 막힌다. (`block_user` 에서 겪은 것과 같은 문제다)
  static Future<bool> likeBoard({
    required String searchId,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return false;
      }

      await supabase.from('board_like').upsert({
        'board_id': searchId,
        'user_uid': user.id,
      }, ignoreDuplicates: true);

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 좋아요를 취소한다. 성공 여부를 bool 로 반환한다.
  ///
  /// 이미 없는 행을 지워도 0행이라 실패로 보이므로, 여기서는 되받아 확인하지 않는다.
  /// (누르지 않은 상태에서 취소가 불릴 일이 없고, 불려도 결과는 같다)
  static Future<bool> unlikeBoard({
    required String searchId,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return false;
      }

      await supabase
          .from('board_like')
          .delete()
          .eq('board_id', searchId)
          .eq('user_uid', user.id);

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 이 유저가 게시글을 봤다는 사실을 기록한다. 성공 여부를 bool 로 반환한다.
  ///
  /// **테이블을 직접 건드리지 않고 RPC 를 부른다.** 중복 판정 원장인 `board_view` 는
  /// 앱에 권한이 아예 없다 — 읽을 수 있으면 "누가 어떤 글을 읽었는지" 가 통째로
  /// 노출되기 때문이다. 서버의 `increment_board_view` 가 원장에 한 번만 넣고
  /// `board.view_count` 를 올린다.
  ///
  /// 그래서 한 사람이 몇 번을 다시 열어도 1 이고, 클라이언트가 카운터에 아무 값이나
  /// 써넣을 수도 없다. (`board` 의 UPDATE 는 `title`·`content` 컬럼에만 열려 있다)
  static Future<bool> viewBoard({
    required String searchId,
  }) async {
    try {
      await supabase.rpc(
        'increment_board_view',
        params: {
          'target_id': searchId,
        },
      );

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 게시글의 제목·내용을 수정한다. 성공 여부를 bool 로 반환한다.
  ///
  /// 바뀐 행을 되받아 실제로 수정됐는지 확인한다. RLS(`board_update_own`)가 막으면
  /// 오류 없이 0행이 바뀌므로, 이 확인이 없으면 실패를 성공으로 보고하게 된다.
  ///
  /// 작성자 이름은 건드리지 않는다. `set_author_name` 트리거는 INSERT 전용이라
  /// UPDATE 에는 걸리지 않고, DB 도 `title`·`content` 컬럼에만 UPDATE 를 허용한다.
  static Future<bool> updateBoard({
    required UpdateBoardParams updateBoardParams,
  }) async {
    try {
      final updatedRows = await supabase
          .from('board')
          .update({
            'title': updateBoardParams.title,
            'content': updateBoardParams.content,
          })
          .eq('id', updateBoardParams.searchId)
          .select('id');

      return updatedRows.isNotEmpty;
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
