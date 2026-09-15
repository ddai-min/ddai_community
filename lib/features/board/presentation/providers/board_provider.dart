import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/providers/pagination_provider.dart';
import 'package:ddai_community/core/providers/session_provider.dart';
import 'package:ddai_community/features/board/data/board_repository.dart';
import 'package:ddai_community/features/board/domain/board_like_model.dart';
import 'package:ddai_community/features/board/domain/board_model.dart';
import 'package:ddai_community/features/board/domain/board_parameter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'board_provider.g.dart';

/// [BoardRepository] 인스턴스 제공.
@Riverpod(keepAlive: true)
BoardRepository boardRepository(Ref ref) => BoardRepository();

/// 상세 화면이 방금 읽어 온 게시글. 목록들이 이 신호를 듣고 자기 항목만 갈아 끼운다.
///
/// 상세를 열면 조회가 **먼저** 기록되어 `view_count` 가 1 오르는데, 목록은 상세를
/// 여닫는 동안 살아 있어서 다시 조회하지 않는다. 이 신호가 없으면 방금 오른 조회수가
/// 목록에서는 옛날 값으로 남는다.
///
/// 캐시가 아니라 **신호**다. 목록은 이걸 받아 자기 상태를 고칠 뿐이라, 나중에 목록을
/// 새로 받으면 서버 값이 자연스럽게 이긴다. (값을 따로 들고 있으면 남이 본 조회까지
/// 반영된 새 값을 옛날 값이 덮어쓰게 된다)
@riverpod
class ViewedBoard extends _$ViewedBoard {
  @override
  BoardModel? build() => null;

  /// 상세에서 읽은 게시글을 기록한다. 값이 그대로면 목록을 흔들지 않는다.
  /// (이미 본 글을 다시 열면 조회수가 오르지 않는다 — 본 사람 수이기 때문이다)
  void record(BoardModel board) {
    if (state?.id == board.id && state?.viewCount == board.viewCount) {
      return;
    }

    state = board;
  }
}

/// [ViewedBoard] 신호를 받아 목록 항목의 조회수를 갱신하는 공통 로직.
///
/// 게시글 목록 셋(`BoardList`·`BoardSearchList`·`MyBoardList`)이 모두 섞어 쓴다.
/// 어느 목록에서 상세로 들어갔는지 상세 화면이 알 필요가 없고, 살아 있는 목록이
/// 알아서 자기 항목을 고친다. (검색 목록은 검색어별 family 라 바깥에서 지목하기 어렵다)
mixin ViewedBoardSync on PaginationMixin<BoardModel> {
  /// `build()` 에서 호출한다.
  ///
  /// **watch 가 아니라 listen 이다.** watch 로 받으면 신호가 올 때마다 목록 자체가
  /// 다시 만들어져 쌓아 둔 페이지가 날아간다.
  void subscribeViewedBoard() {
    ref.listen(viewedBoardProvider, (_, viewed) {
      // 스키마 적용 전 응답은 조회수가 null 이다. 그때는 건드리지 않는다.
      if (viewed == null || viewed.viewCount == null) {
        return;
      }

      updateItem(
        viewed.id,
        (item) => item.copyWith(viewCount: viewed.viewCount),
      );
    });
  }
}

/// 게시글 목록(페이지네이션) Notifier.
@riverpod
class BoardList extends _$BoardList
    with PaginationMixin<BoardModel>, ViewedBoardSync {
  @override
  PaginationModel<BoardModel> build() {
    subscribeViewedBoard();

    return initialState();
  }

  @override
  PaginationRepository<BoardModel> get paginationRepository =>
      ref.read(boardRepositoryProvider);
}

/// 게시글 검색 목록. 검색어별로 생성된다.
///
/// 목록 화면의 [boardListProvider] 를 family 로 바꾸지 않고 따로 둔다.
/// 새로고침을 부르는 곳이 여럿이라(작성·삭제·차단) 인자가 붙으면 전부 바뀐다.
@riverpod
class BoardSearchList extends _$BoardSearchList
    with PaginationMixin<BoardModel>, ViewedBoardSync {
  // build 는 유저 변경 시 재실행될 수 있고 Notifier 인스턴스는 유지되므로 late final 이 아니다.
  late String _keyword;

  @override
  PaginationModel<BoardModel> build(String searchKeyword) {
    _keyword = searchKeyword;

    subscribeViewedBoard();

    return initialState();
  }

  @override
  PaginationRepository<BoardModel> get paginationRepository =>
      ref.read(boardRepositoryProvider);

  // 훑을 컬럼(title·content)은 BoardRepository 가 searchColumns 로 들고 있다.
  @override
  String? get keyword => _keyword;
}

/// 내가 쓴 게시글 목록.
@riverpod
class MyBoardList extends _$MyBoardList
    with PaginationMixin<BoardModel>, ViewedBoardSync {
  @override
  PaginationModel<BoardModel> build() {
    subscribeViewedBoard();

    return initialState();
  }

  @override
  PaginationRepository<BoardModel> get paginationRepository =>
      ref.read(boardRepositoryProvider);

  // initialState() 가 세션을 watch 하므로 로그인 유저가 바뀌면 목록이 다시 만들어진다.
  @override
  String? get userUid => ref.read(sessionUidProvider);
}

/// 게시글 단건 조회. searchId(게시글 id)별로 캐싱된다.
@riverpod
Future<BoardModel?> getBoard(Ref ref, String searchId) =>
    BoardRepository.getBoard(searchId: searchId);

/// 게시글 작성. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> addBoard(Ref ref, AddBoardParams params) =>
    BoardRepository.addBoard(addBoardParams: params);

/// 게시글 하나의 좋아요 상태. 게시글 id 별로 생성된다.
///
/// 서버 왕복을 기다리지 않고 **먼저 그린 뒤** 반영한다. 실패하면 되돌린다 —
/// 하트는 누르자마자 반응해야 하는데 왕복이 눈에 띄기 때문이다.
@riverpod
class BoardLike extends _$BoardLike {
  @override
  Future<BoardLikeModel> build(String boardId) =>
      BoardRepository.getBoardLike(searchId: boardId);

  /// 좋아요를 켜고 끈다.
  Future<void> toggle() async {
    final current = state.value;

    if (current == null) {
      return;
    }

    state = AsyncData(
      BoardLikeModel(
        count: current.isLiked ? current.count - 1 : current.count + 1,
        isLiked: !current.isLiked,
      ),
    );

    final isSuccess = current.isLiked
        ? await BoardRepository.unlikeBoard(searchId: boardId)
        : await BoardRepository.likeBoard(searchId: boardId);

    if (!isSuccess) {
      state = AsyncData(current);
    }
  }
}

/// 게시글 수정. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> updateBoard(Ref ref, UpdateBoardParams params) =>
    BoardRepository.updateBoard(updateBoardParams: params);

/// 게시글 삭제. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> deleteBoard(Ref ref, String searchId) =>
    BoardRepository.deleteBoard(searchId: searchId);
