import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/board/model/board_parameter.dart';
import 'package:ddai_community/board/repository/board_repository.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/provider/pagination_provider.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [BoardRepository] 인스턴스 제공.
final boardRepositoryProvider = Provider(
  (ref) => BoardRepository(),
);

/// 게시글 목록(페이지네이션) Notifier.
class BoardListNotifier extends PaginationNotifier<BoardModel> {
  @override
  PaginationRepository<BoardModel> readRepository() =>
      ref.watch(boardRepositoryProvider);

  @override
  CollectionPath get collectionPath => CollectionPath.board;
}

/// 게시글 목록(페이지네이션) 상태. 로그인 유저가 바뀌면 자동으로 다시 만들어진다.
final getBoardListProvider =
    NotifierProvider.autoDispose<BoardListNotifier, PaginationModel<BoardModel>>(
  BoardListNotifier.new,
);

/// 게시글 단건 조회. searchId(게시글 id)별로 캐싱된다.
final getBoardProvider = FutureProvider.family
    .autoDispose<BoardModel?, String>((ref, searchId) async {
  final result = await BoardRepository.getBoard(
    searchId: searchId,
  );

  return result;
});

/// 게시글 작성. 결과로 성공 여부(bool)를 반환한다.
final addBoardProvider = FutureProvider.family
    .autoDispose<bool, AddBoardParams>((ref, params) async {
  final result = await BoardRepository.addBoard(
    addBoardParams: params,
  );

  return result;
});

/// 게시글 삭제. 결과로 성공 여부(bool)를 반환한다.
final deleteBoardProvider =
    FutureProvider.family.autoDispose<bool, String>((ref, searchId) async {
  final result = await BoardRepository.deleteBoard(
    searchId: searchId,
  );

  return result;
});
