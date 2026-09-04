import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:ddai_community/core/widgets/default_list_placeholder.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/board/presentation/screens/board_detail_screen.dart';
import 'package:ddai_community/features/board/presentation/widgets/board_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BoardListScreen extends ConsumerStatefulWidget {
  const BoardListScreen({super.key});

  @override
  ConsumerState<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends ConsumerState<BoardListScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(boardListProvider.notifier).fetchData();
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
    final boardList = ref.watch(boardListProvider);

    if (boardList.items.isEmpty && boardList.isLoading) {
      return const Center(
        child: DefaultCircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: Colors.white,
      onRefresh: () async {
        ref.read(boardListProvider.notifier).refresh();
      },
      // 비었을 때도 스크롤 가능한 위젯을 두어야 당겨서 새로고침이 동작한다.
      child: boardList.items.isEmpty
          ? _renderPlaceholder(
              context: context,
              hasError: boardList.hasError,
            )
          : ListView.builder(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
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
                    context.goNamed(
                      BoardDetailScreen.routeName,
                      pathParameters: {
                        'id': board.id,
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  /// 목록이 비었을 때 자리에 놓는 안내.
  ///
  /// 조회 실패와 "글이 없음" 을 구분한다. 둘 다 빈 목록으로 돌아오기 때문이다.
  /// 스크롤 가능한 위젯으로 감싸야 이 상태에서도 당겨서 새로고침이 된다.
  Widget _renderPlaceholder({
    required BuildContext context,
    required bool hasError,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: DefaultListPlaceholder(
            message: hasError
                ? '게시글을 불러오지 못했습니다.\n네트워크 상태를 확인해주세요.'
                : '아직 게시글이 없습니다.\n첫 글을 남겨보세요.',
            onRetry: hasError
                ? () {
                    ref.read(boardListProvider.notifier).refresh();
                  }
                : null,
          ),
        ),
      ],
    );
  }

  /// 스크롤이 목록 끝(200px 이내)에 도달하면 다음 페이지를 불러온다. (무한 스크롤)
  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(boardListProvider.notifier).fetchData();
    }
  }
}
