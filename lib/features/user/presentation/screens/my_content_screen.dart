import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/utils/data_utils.dart';
import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/default_list_placeholder.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/board/presentation/providers/comment_provider.dart';
import 'package:ddai_community/features/board/presentation/screens/board_detail_screen.dart';
import 'package:ddai_community/features/board/presentation/widgets/board_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 내가 쓴 글·댓글 화면. (프로필 탭에서 진입)
///
/// 프로필에 닉네임과 메뉴만 있어서 자기가 쓴 글을 다시 찾아갈 방법이 없었다.
/// 목록 자체는 게시판과 같은 커서 페이지네이션을 쓰고, `user_uid` 로만 좁힌다.
class MyContentScreen extends ConsumerStatefulWidget {
  static String get routeName => 'my_content';

  const MyContentScreen({super.key});

  @override
  ConsumerState<MyContentScreen> createState() => _MyContentScreenState();
}

class _MyContentScreenState extends ConsumerState<MyContentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void dispose() {
    tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '내가 쓴 글',
      // 탭 본문이 스스로 스크롤한다.
      isScrollable: false,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            labelColor: primaryColor,
            indicatorColor: primaryColor,
            tabs: const [
              Tab(text: '게시글'),
              Tab(text: '댓글'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                _MyBoardList(),
                _MyCommentList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 내가 쓴 게시글 목록.
class _MyBoardList extends ConsumerStatefulWidget {
  const _MyBoardList();

  @override
  ConsumerState<_MyBoardList> createState() => _MyBoardListState();
}

class _MyBoardListState extends ConsumerState<_MyBoardList> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(myBoardListProvider.notifier).fetchData();
    });

    scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_listener);
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardList = ref.watch(myBoardListProvider);

    if (boardList.items.isEmpty) {
      if (boardList.isLoading) {
        return const Center(
          child: DefaultCircularProgressIndicator(),
        );
      }

      return DefaultListPlaceholder(
        message: boardList.hasError
            ? '목록을 불러오지 못했습니다.\n네트워크 상태를 확인해주세요.'
            : '아직 쓴 게시글이 없습니다.',
        onRetry: boardList.hasError
            ? () {
                ref.read(myBoardListProvider.notifier).refresh();
              }
            : null,
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: DefaultLayout.contentPadding,
      clipBehavior: Clip.none,
      itemCount: boardList.items.length + (boardList.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == boardList.items.length) {
          return const Center(
            child: DefaultCircularProgressIndicator(),
          );
        }

        final board = boardList.items[index];

        return BoardListItem(
          title: board.title,
          content: board.content,
          userName: board.userName,
          date: board.date,
          commentCount: board.commentCount,
          likeCount: board.likeCount,
          onTap: () {
            context.pushNamed(
              BoardDetailScreen.routeName,
              pathParameters: {
                'id': board.id,
              },
            );
          },
        );
      },
    );
  }

  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(myBoardListProvider.notifier).fetchData();
    }
  }
}

/// 내가 쓴 댓글 목록. 누르면 댓글이 달린 원글로 이동한다.
class _MyCommentList extends ConsumerStatefulWidget {
  const _MyCommentList();

  @override
  ConsumerState<_MyCommentList> createState() => _MyCommentListState();
}

class _MyCommentListState extends ConsumerState<_MyCommentList> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(myCommentListProvider.notifier).fetchData();
    });

    scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_listener);
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentList = ref.watch(myCommentListProvider);

    if (commentList.items.isEmpty) {
      if (commentList.isLoading) {
        return const Center(
          child: DefaultCircularProgressIndicator(),
        );
      }

      return DefaultListPlaceholder(
        message: commentList.hasError
            ? '목록을 불러오지 못했습니다.\n네트워크 상태를 확인해주세요.'
            : '아직 쓴 댓글이 없습니다.',
        onRetry: commentList.hasError
            ? () {
                ref.read(myCommentListProvider.notifier).refresh();
              }
            : null,
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: DefaultLayout.contentPadding,
      clipBehavior: Clip.none,
      itemCount: commentList.items.length + (commentList.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == commentList.items.length) {
          return const Center(
            child: DefaultCircularProgressIndicator(),
          );
        }

        final comment = commentList.items[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            comment.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            DataUtils.formatRelativeDate(comment.date),
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
          onTap: () {
            context.pushNamed(
              BoardDetailScreen.routeName,
              pathParameters: {
                'id': comment.boardId,
              },
            );
          },
        );
      },
    );
  }

  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(myCommentListProvider.notifier).fetchData();
    }
  }
}
