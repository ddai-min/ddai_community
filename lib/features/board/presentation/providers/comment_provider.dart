import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/providers/pagination_provider.dart';
import 'package:ddai_community/features/board/data/comment_repository.dart';
import 'package:ddai_community/features/board/domain/comment_model.dart';
import 'package:ddai_community/features/board/domain/comment_parameter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comment_provider.g.dart';

/// [CommentRepository] 인스턴스 제공.
@Riverpod(keepAlive: true)
CommentRepository commentRepository(Ref ref) => CommentRepository();

/// 특정 게시글의 댓글 목록(페이지네이션) Notifier. 게시글 id로 family 생성된다.
@riverpod
class CommentList extends _$CommentList with PaginationMixin<CommentModel> {
  // build 는 유저 변경 시 재실행될 수 있고 Notifier 인스턴스는 유지되므로 late final 이 아니다.
  late String _boardId;

  @override
  PaginationModel<CommentModel> build(String boardId) {
    _boardId = boardId;
    return initialState();
  }

  @override
  PaginationRepository<CommentModel> get paginationRepository =>
      ref.read(commentRepositoryProvider);

  // Firestore 의 하위 컬렉션 대신 comment.board_id FK 로 범위를 좁힌다.
  // (좁힐 컬럼 이름은 CommentRepository 가 parentColumn 으로 들고 있다)
  @override
  String? get parentId => _boardId;
}

/// 댓글 작성. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> addComment(Ref ref, AddCommentParams params) =>
    CommentRepository.addComment(addCommentParams: params);

/// 댓글 삭제. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> deleteComment(Ref ref, String searchId) =>
    CommentRepository.deleteComment(searchId: searchId);
