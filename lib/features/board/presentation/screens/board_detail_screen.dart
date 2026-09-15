import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/widgets/content_action_sheet.dart';
import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/default_list_placeholder.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/text_field_dialog.dart';
import 'package:ddai_community/features/board/domain/comment_model.dart';
import 'package:ddai_community/features/board/domain/comment_parameter.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/board/presentation/providers/comment_provider.dart';
import 'package:ddai_community/features/board/presentation/widgets/board_detail_buttons.dart';
import 'package:ddai_community/features/board/presentation/widgets/board_like_button.dart';
import 'package:ddai_community/features/board/presentation/widgets/comment_list_item.dart';
import 'package:ddai_community/features/board/presentation/widgets/comment_text_field.dart';
import 'package:ddai_community/features/chat/presentation/providers/chat_provider.dart';
import 'package:ddai_community/features/user/domain/report_parameter.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:ddai_community/features/user/presentation/widgets/report_block_actions.dart';
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

    // 이 화면을 여는 순간 조회가 먼저 기록되어 조회수가 1 오른다. 목록은 상세를 여닫는
    // 동안 살아 있어 다시 조회하지 않으므로, 읽어 온 최신 값을 목록 쪽으로 흘려보낸다.
    // (build 중에는 다른 provider 를 고칠 수 없어 watch 가 아니라 listen 으로 받는다)
    ref.listen(getBoardProvider(widget.id), (_, next) {
      final data = next.value;

      if (data == null) {
        return;
      }

      ref.read(viewedBoardProvider.notifier).record(data);
    });

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
                viewCount: data.viewCount,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BoardLikeButton(
                boardId: widget.id,
              ),
            ),
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
    // build 에서 부르므로 watch 다. 로그인 상태가 늦게 채워져도 버튼이 따라 바뀐다.
    if (ref.watch(userMeProvider).id == userUid) {
      return [
        BoardEditButton(
          boardId: widget.id,
        ),
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
          userName: userName,
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

  /// 이 글을 본 사람 수. 여는 순간 내 조회가 먼저 기록되므로 나도 포함된 값이다.
  /// (`BoardRepository.getBoard` 가 읽기 직전에 넣는다)
  final int? viewCount;

  const _Writing({
    required this.title,
    required this.userName,
    required this.content,
    this.viewCount,
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
        Row(
          children: [
            // 긴 닉네임이 조회수를 밀어내지 않도록 이름 쪽만 줄인다.
            Expanded(
              child: Text(
                '작성자: $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ),
            if (viewCount != null)
              Text(
                '조회 $viewCount',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
          ],
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
    // itemBuilder 는 build 가 아니라 레이아웃 중에 불리므로 여기서 미리 구독한다.
    final myUid = ref.watch(userMeProvider).id;

    if (commentList.items.isEmpty) {
      if (commentList.isLoading) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: DefaultCircularProgressIndicator(),
          ),
        );
      }

      // 조회 실패와 "댓글 없음" 을 구분한다. 둘 다 빈 목록으로 돌아오기 때문이다.
      return SizedBox(
        height: 100,
        child: DefaultListPlaceholder(
          message: commentList.hasError ? '댓글을 불러오지 못했습니다.' : '댓글이 없습니다.',
          onRetry: commentList.hasError
              ? () {
                  ref.read(commentListProvider(boardId).notifier).refresh();
                }
              : null,
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
            onMenuPressed: () {
              _showActions(
                context: context,
                ref: ref,
                comment: comment,
                isMine: comment.userUid == myUid,
              );
            },
          );
        },
      );
    }
  }

  /// 댓글 오른쪽 메뉴. 내 댓글이면 삭제만, 남의 댓글이면 신고·차단이 뜬다.
  void _showActions({
    required BuildContext context,
    required WidgetRef ref,
    required CommentModel comment,
    required bool isMine,
  }) {
    showContentActionSheet(
      context: context,
      actions: isMine
          ? [
              ContentAction(
                label: '수정',
                icon: Icons.edit_outlined,
                onPressed: () {
                  _editComment(
                    context: context,
                    ref: ref,
                    comment: comment,
                  );
                },
              ),
              ContentAction(
                label: '삭제',
                icon: Icons.delete_outline,
                isDestructive: true,
                onPressed: () {
                  _confirmDelete(
                    context: context,
                    ref: ref,
                    commentId: comment.id,
                  );
                },
              ),
            ]
          : [
              ContentAction(
                label: '신고',
                icon: Icons.flag_outlined,
                onPressed: () {
                  showReportDialog(
                    context: context,
                    ref: ref,
                    contentType: ReportContentType.comment,
                    contentId: comment.id,
                    userUid: comment.userUid,
                    userName: comment.userName,
                  );
                },
              ),
              ContentAction(
                label: '차단',
                icon: Icons.block,
                isDestructive: true,
                onPressed: () {
                  showBlockDialog(
                    context: context,
                    ref: ref,
                    userUid: comment.userUid,
                    userName: comment.userName,
                    onBlocked: () {
                      // 차단은 RLS 가 조회 시점에 거른다. 목록을 다시 받아야 걷힌다.
                      ref.read(commentListProvider(boardId).notifier).refresh();
                      ref.read(boardListProvider.notifier).refresh();
                      ref.invalidate(chatListProvider);
                    },
                  );
                },
              ),
            ],
    );
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

  /// 내 댓글 내용을 고친다.
  ///
  /// 값을 꺼내 두고 다이얼로그를 **먼저 닫는다.** 컨트롤러가 다이얼로그와 함께
  /// 사라져서 닫힌 뒤에는 읽을 수 없다. (`showReportDialog` 와 같은 모양)
  void _editComment({
    required BuildContext context,
    required WidgetRef ref,
    required CommentModel comment,
  }) async {
    final commentTextController = TextEditingController(text: comment.content);
    String? content;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return TextFieldDialog(
          textController: commentTextController,
          contentText: '댓글을 수정합니다.',
          hintText: '댓글 내용',
          buttonText: '저장',
          // DB 의 CHECK 제약과 같은 값이어야 한다. 어긋나면 저장만 조용히 실패한다.
          maxLength: 100,
          onPressed: () {
            content = commentTextController.text.trim();

            dialogContext.pop();
          },
        );
      },
    );

    commentTextController.dispose();

    // 저장을 누르지 않고 닫았으면(바깥 탭 등) 아무 일도 하지 않는다.
    if (content == null || !context.mounted) {
      return;
    }

    if (content!.isEmpty) {
      // 빈 댓글은 만들 수 없다. 지우려는 것이면 삭제를 쓰게 둔다.
      _notify(
        context: context,
        message: '댓글 내용을 입력해주세요.',
      );

      return;
    }

    if (content == comment.content) {
      return;
    }

    final isUpdate = await ref.read(
      updateCommentProvider(
        UpdateCommentParams(
          searchId: comment.id,
          content: content!,
        ),
      ).future,
    );

    if (isUpdate) {
      ref.read(commentListProvider(boardId).notifier).refresh();

      return;
    }

    if (!context.mounted) {
      return;
    }

    _notify(
      context: context,
      message: '댓글을 수정하지 못했습니다.\n잠시 후 다시 시도해주세요.',
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

    _notify(
      context: context,
      message: '댓글을 삭제하지 못했습니다.\n잠시 후 다시 시도해주세요.',
    );
  }

  /// 확인 버튼 하나짜리 안내 다이얼로그.
  void _notify({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return DefaultDialog(
          contentText: message,
          buttonText: '확인',
          onPressed: () {
            dialogContext.pop();
          },
        );
      },
    );
  }
}
