import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/board/repository/board_repository.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/provider/pagination_provider.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddBoardParams {
  final String title;
  final String content;
  final String userName;

  AddBoardParams({
    required this.title,
    required this.content,
    required this.userName,
  });
}

class AddCommentParams {
  final String searchId;
  final String userName;
  final String content;

  AddCommentParams({
    required this.searchId,
    required this.userName,
    required this.content,
  });
}

final boardRepositoryProvider = Provider(
  (ref) => BoardRepository(),
);

// 게시글 목록 GET
final getBoardListProvider = StateNotifierProvider<
    PaginationProvider<BoardModel>, PaginationModel<BoardModel>>((ref) {
  final repository = ref.watch(boardRepositoryProvider);

  return PaginationProvider<BoardModel>(
    paginationRepository: repository,
    collectionPath: CollectionPath.board,
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
    title: params.title,
    content: params.content,
    userName: params.userName,
  );

  return result;
});

// 댓글 ADD
final addCommentProvider = FutureProvider.family
    .autoDispose<bool, AddCommentParams>((ref, params) async {
  final result = await BoardRepository.addComment(
    searchId: params.searchId,
    userName: params.userName,
    content: params.content,
  );

  return result;
});
