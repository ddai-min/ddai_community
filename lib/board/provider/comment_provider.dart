import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/board/model/comment_parameter.dart';
import 'package:ddai_community/board/repository/comment_repository.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/provider/pagination_provider.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [CommentRepository] 인스턴스 제공.
final commentRepositoryProvider = Provider(
  (ref) => CommentRepository(),
);

/// 특정 게시글의 댓글 목록(페이지네이션) Notifier. 게시글 id로 family 생성된다.
class CommentListNotifier extends PaginationNotifier<CommentModel> {
  CommentListNotifier(this.boardId);

  /// 댓글을 조회할 대상 게시글 id. (family 인자)
  final String boardId;

  @override
  PaginationRepository<CommentModel> readRepository() =>
      ref.watch(commentRepositoryProvider);

  @override
  CollectionPath get collectionPath => CollectionPath.board;

  @override
  CollectionPath? get subCollectionPath => CollectionPath.comment;

  @override
  String? get collectionId => boardId;
}

/// 특정 게시글의 댓글 목록(페이지네이션) 상태. 게시글 id별로 관리된다.
final getCommentListProvider = NotifierProvider.autoDispose
    .family<CommentListNotifier, PaginationModel<CommentModel>, String>(
  CommentListNotifier.new,
);

/// 댓글 작성. 결과로 성공 여부(bool)를 반환한다.
final addCommentProvider = FutureProvider.family
    .autoDispose<bool, AddCommentParams>((ref, params) async {
  final result = await CommentRepository.addComment(
    addCommentParams: params,
  );

  return result;
});
