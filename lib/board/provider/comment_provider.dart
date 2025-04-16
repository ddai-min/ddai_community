import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/board/repository/comment_repository.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/provider/pagination_provider.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCommentParams {
  final String searchId;
  final String userName;
  final String userUid;
  final String content;

  AddCommentParams({
    required this.searchId,
    required this.userName,
    required this.userUid,
    required this.content,
  });
}

final commentRepositoryProvider = Provider(
  (ref) => CommentRepository(),
);

// 댓글 GET
final getCommentListProvider = StateNotifierProvider.family.autoDispose<
    PaginationProvider<CommentModel>,
    PaginationModel<CommentModel>,
    String>((ref, collectionId) {
  final user = ref.watch(userMeProvider);
  final repository = ref.watch(commentRepositoryProvider);

  return PaginationProvider<CommentModel>(
    paginationRepository: repository,
    userUid: user.id,
    collectionPath: CollectionPath.board,
    subCollectionPath: CollectionPath.comment,
    collectionId: collectionId,
    isUsingStream: false,
  );
});

// 댓글 ADD
final addCommentProvider = FutureProvider.family
    .autoDispose<bool, AddCommentParams>((ref, params) async {
  final result = await CommentRepository.addComment(
    searchId: params.searchId,
    userName: params.userName,
    userUid: params.userUid,
    content: params.content,
  );

  return result;
});
