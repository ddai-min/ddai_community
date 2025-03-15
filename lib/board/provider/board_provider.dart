import 'package:ddai_community/board/model/board_model.dart';
import 'package:ddai_community/board/repository/board_repository.dart';
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

// 게시글 목록 GET
final getBoardListProvider =
    FutureProvider.autoDispose<List<BoardModel>>((ref) async {
  final result = await BoardRepository.getBoardList();

  return result;
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
