import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/providers/pagination_provider.dart';
import 'package:ddai_community/features/board/data/board_repository.dart';
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

/// 게시글 단건 조회. searchId(게시글 id)별로 캐싱된다.
@riverpod
Future<BoardModel?> getBoard(Ref ref, String searchId) =>
    BoardRepository.getBoard(searchId: searchId);

/// 게시글 작성. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> addBoard(Ref ref, AddBoardParams params) =>
    BoardRepository.addBoard(addBoardParams: params);

/// 게시글 삭제. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> deleteBoard(Ref ref, String searchId) =>
    BoardRepository.deleteBoard(searchId: searchId);
