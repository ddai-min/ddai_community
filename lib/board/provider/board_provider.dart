import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/board/model/board_parameter.dart';
import 'package:ddai_community/board/repository/board_repository.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/provider/pagination_provider.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final boardRepositoryProvider = Provider(
  (ref) => BoardRepository(),
);

// 게시글 목록 GET
final getBoardListProvider = StateNotifierProvider.autoDispose<
    PaginationProvider<BoardModel>, PaginationModel<BoardModel>>((ref) {
  final user = ref.watch(userMeProvider);
  final repository = ref.watch(boardRepositoryProvider);

  return PaginationProvider<BoardModel>(
    paginationRepository: repository,
    userUid: user.id,
    collectionPath: CollectionPath.board,
    isUsingStream: false,
  );
});

// 게시글 GET
final getBoardProvider = FutureProvider.family
    .autoDispose<BoardModel?, String>((ref, searchId) async {
  final result = await BoardRepository.getBoard(
    searchId: searchId,
  );

  return result;
});

// 게시글 ADD
final addBoardProvider = FutureProvider.family
    .autoDispose<bool, AddBoardParams>((ref, params) async {
  final result = await BoardRepository.addBoard(
    addBoardParams: params,
  );

  return result;
});

// 게시글 DELETE
final deleteBoardProvider =
    FutureProvider.family.autoDispose<bool, String>((ref, searchId) async {
  final result = await BoardRepository.deleteBoard(
    searchId: searchId,
  );

  return result;
});
