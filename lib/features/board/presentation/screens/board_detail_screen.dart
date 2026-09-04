import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/features/board/domain/comment_model.dart';
import 'package:ddai_community/features/board/domain/comment_parameter.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/board/presentation/providers/comment_provider.dart';
import 'package:ddai_community/features/board/presentation/widgets/board_detail_buttons.dart';
import 'package:ddai_community/features/board/presentation/widgets/comment_list_item.dart';
import 'package:ddai_community/features/board/presentation/widgets/comment_text_field.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BoardDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'board_detail';

  final String id;

  const BoardDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends ConsumerState<BoardDetailScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(commentListProvider(widget.id).notifier).fetchData();
    });

    scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_listener);
    scrollController.dispose();
    commentTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(getBoardProvider(widget.id));
    final commentList = ref.watch(commentListProvider(widget.id));

    return board.when(
      loading: () => const DefaultLayout(
        title: '',
        // Center 는 스크롤뷰 안에서 내용 높이만큼 줄어 가운데 정렬이 풀린다.
        isScrollable: false,
        child: Center(
          child: DefaultCircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const DefaultLayout(
        title: '',
        isScrollable: false,
        child: Center(
          child: Text('로딩 중에 오류가 발생하였습니다.'),
        ),
      ),
      data: (data) => DefaultLayout(
        padding: EdgeInsetsGeometry.zero,
        // 스크롤 위치로 다음 댓글 페이지를 불러온다.
        scrollController: scrollController,
        title: data!.title,
        actions: _renderActions(
          userUid: data.userUid,
          userName: data.userName,
        ),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _Writing(
                title: data.title,
                userName: data.userName,
                content: data.content,
              ),
            ),
            const SizedBox(height: 16.0),
            CommentTextField(
              controller: commentTextController,
              onPressed: _addComment,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _CommentList(
                boardId: widget.id,
                commentList: commentList,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AppBar 우측 액션 버튼을 상황에 맞게 구성한다.
  ///
  /// 내 글이면 삭제 버튼을, 남의 글이면 신고·차단 버튼을 보여준다.
  List<Widget>? _renderActions({
    required String userUid,
    required String userName,
  }) {
    if (ref.read(userMeProvider).id == userUid) {
      return [
        BoardDeleteButton(
          boardId: widget.id,
        ),
      ];
    } else {
      return [
        BoardReportButton(
          userUid: userUid,
          userName: userName,
          boardId: widget.id,
        ),
        BoardBlockButton(
          userUid: userUid,
        ),
      ];
    }
  }

  Future<void> _addComment() async {
    if (commentTextController.text.isEmpty) {
      return;
    }

    final isSuccessed = await ref.read(
      addCommentProvider(
        AddCommentParams(
          searchId: widget.id,
          userName: ref.read(userMeProvider).userName,
          userUid: ref.read(userMeProvider).id,
          content: commentTextController.text,
        ),
      ).future,
    );

    if (isSuccessed) {
      commentTextController.text = '';

      ref.read(commentListProvider(widget.id).notifier).refresh();
    }
  }

  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(commentListProvider(widget.id).notifier).fetchData();
    }
  }
}

class _Writing extends StatelessWidget {
  final String title;
  final String userName;
  final String content;

  const _Writing({
    required this.title,
    required this.userName,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '작성자: $userName',
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16.0),
        const Divider(),
        const SizedBox(height: 16.0),
        Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentList extends ConsumerWidget {
  /// 삭제 후 목록을 다시 읽을 때 필요하다. (댓글 목록은 게시글 id 로 family 생성된다)
  final String boardId;
  final PaginationModel<CommentModel> commentList;

  const _CommentList({
    required this.boardId,
    required this.commentList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (commentList.items.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: commentList.isLoading
              ? const DefaultCircularProgressIndicator()
              : const Text('댓글이 없습니다.'),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: commentList.items.length + (commentList.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == commentList.items.length) {
            return const Center(
              child: DefaultCircularProgressIndicator(),
            );
          }

          final comment = commentList.items[index];

          return CommentListItem(
            commentModel: comment,
            isMine: comment.userUid == ref.read(userMeProvider).id,
            onDelete: () {
              _confirmDelete(
                context: context,
                ref: ref,
                commentId: comment.id,
              );
            },
          );
        },
      );
    }
  }

  void _confirmDelete({
    required BuildContext context,
    required WidgetRef ref,
    required String commentId,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return DefaultDialog(
          titleText: '댓글 삭제',
          contentText: '정말로 삭제하시겠습니까?',
          buttonText: '삭제',
          onPressed: () {
            dialogContext.pop();

            _deleteComment(
              context: context,
              ref: ref,
              commentId: commentId,
            );
          },
        );
      },
    );
  }

  void _deleteComment({
    required BuildContext context,
    required WidgetRef ref,
    required String commentId,
  }) async {
    final isDelete = await ref.read(
      deleteCommentProvider(commentId).future,
    );

    if (isDelete) {
      ref.read(commentListProvider(boardId).notifier).refresh();

      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return DefaultDialog(
          contentText: '댓글을 삭제하지 못했습니다.\n잠시 후 다시 시도해주세요.',
          buttonText: '확인',
          onPressed: () {
            dialogContext.pop();
          },
        );
      },
    );
  }
}
