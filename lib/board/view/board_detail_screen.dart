import 'package:ddai_community/board/component/comment_list_item.dart';
import 'package:ddai_community/board/component/comment_text_field.dart';
import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/board/provider/board_provider.dart';
import 'package:ddai_community/board/provider/comment_provider.dart';
import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/component/text_field_dialog.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/auth_provider.dart';
import 'package:ddai_community/user/provider/report_provider.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BoardDetailScreen extends ConsumerStatefulWidget {
  static get routeName => 'board_detail';

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
  TextEditingController reportTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(getCommentListProvider(widget.id).notifier).fetchData();
    });

    scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_listener);
    scrollController.dispose();
    commentTextController.dispose();
    reportTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(getBoardProvider(widget.id));
    final commentList = ref.watch(getCommentListProvider(widget.id));

    return board.when(
      loading: () => const DefaultLayout(
        title: '',
        child: Center(
          child: DefaultCircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const DefaultLayout(
        title: '',
        child: Center(
          child: Text('로딩 중에 오류가 발생하였습니다.'),
        ),
      ),
      data: (data) => DefaultLayout(
        title: data!.title,
        actions: _renderActions(
          userUid: data.userUid,
          userName: data.userName,
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                _Writing(
                  title: data.title,
                  userName: data.userName,
                  content: data.content,
                ),
                const SizedBox(height: 16.0),
                CommentTextField(
                  controller: commentTextController,
                  onPressed: _addComment,
                ),
                _CommentList(
                  commentList: commentList,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget>? _renderActions({
    required String userUid,
    required String userName,
  }) {
    if (ref.read(userMeProvider).id == userUid) {
      return [
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) {
                return DefaultDialog(
                  titleText: '게시글 삭제',
                  contentText: '정말로 삭제하시겠습니까?',
                  buttonText: '삭제',
                  onPressed: _deleteBoard,
                );
              },
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: const Text('삭제'),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) {
                return TextFieldDialog(
                  textController: reportTextController,
                  contentText: '신고 사유를 입력해주세요.',
                  hintText: '신고 사유',
                  buttonText: '신고',
                  onPressed: () {
                    _reportBoard(
                      userName: userName,
                      userUid: userUid,
                    );
                  },
                );
              },
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: const Text('신고'),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) {
                return DefaultDialog(
                  contentText: '작성자를 차단하시겠습니까?',
                  buttonText: '차단',
                  onPressed: () {
                    _blockUser(
                      userMe: ref.read(userMeProvider),
                      blockUserUid: userUid,
                    );
                  },
                );
              },
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: const Text('차단'),
        ),
      ];
    }
  }

  void _deleteBoard() async {
    final isDelete = await ref.read(
      deleteBoardProvider(widget.id).future,
    );

    if (isDelete) {
      ref.read(getBoardListProvider.notifier).refresh();

      context.goNamed(
        HomeTab.routeName,
      );
    }
  }

  void _reportBoard({
    required String userName,
    required String userUid,
  }) async {
    final isReportSuccess = await ref.read(
      reportProvider(
        ReportParams(
          reporterUserName: ref.read(userMeProvider).userName,
          reporterUserUid: ref.read(userMeProvider).id,
          reportedUserName: userName,
          reportedUserUid: userUid,
          reportReason: reportTextController.text,
          reportContentId: widget.id,
        ),
      ).future,
    );

    if (isReportSuccess) {
      reportTextController.text = '';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return DefaultDialog(
            titleText: '신고 완료',
            contentText: '신고가 완료되었습니다.',
            buttonText: '확인',
            onPressed: () {
              context.pop();
              context.pop();
            },
          );
        },
      );
    }
  }

  void _blockUser({
    required UserModel userMe,
    required String blockUserUid,
  }) async {
    if (userMe.isAnonymous) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return DefaultDialog(
            contentText: '로그인 후\n차단할 수 있습니다.',
            buttonText: '확인',
            onPressed: () {
              context.pop();
              context.pop();
            },
          );
        },
      );

      return;
    }

    final isBlockSuccess = await ref.read(
      blockUserProvider(
        blockUserUid,
      ).future,
    );

    if (isBlockSuccess) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return DefaultDialog(
            titleText: '차단 완료',
            contentText: '차단이 완료되었습니다.',
            buttonText: '확인',
            onPressed: () {
              ref.read(getBoardListProvider.notifier).refresh();

              context.goNamed(
                HomeTab.routeName,
              );
            },
          );
        },
      );
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

      ref.read(getCommentListProvider(widget.id).notifier).refresh();
    }
  }

  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(getCommentListProvider(widget.id).notifier).fetchData();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
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
      ),
    );
  }
}

class _CommentList extends StatelessWidget {
  final PaginationModel<CommentModel> commentList;

  const _CommentList({
    required this.commentList,
  });

  @override
  Widget build(BuildContext context) {
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
          );
        },
      );
    }
  }
}
