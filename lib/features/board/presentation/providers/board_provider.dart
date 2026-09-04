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

/// 게시글 목록(페이지네이션) Notifier.
@riverpod
class BoardList extends _$BoardList with PaginationMixin<BoardModel> {
  @override
  PaginationModel<BoardModel> build() => initialState();

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
    with PaginationMixin<BoardModel> {
  // build 는 유저 변경 시 재실행될 수 있고 Notifier 인스턴스는 유지되므로 late final 이 아니다.
  late String _keyword;

  @override
  PaginationModel<BoardModel> build(String searchKeyword) {
    _keyword = searchKeyword;

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
class MyBoardList extends _$MyBoardList with PaginationMixin<BoardModel> {
  @override
  PaginationModel<BoardModel> build() => initialState();

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
