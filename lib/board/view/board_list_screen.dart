import 'package:ddai_community/board/component/board_list_item.dart';
import 'package:ddai_community/board/provider/board_provider.dart';
import 'package:ddai_community/board/view/board_detail_screen.dart';
import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:ddai_community/common/const/colors.dart';
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
      ref.read(getBoardListProvider.notifier).fetchData();
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
    final boardList = ref.watch(getBoardListProvider);

    if (boardList.items.isEmpty && boardList.isLoading) {
      return const Center(
        child: DefaultCircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: Colors.white,
      onRefresh: () async {
        ref.read(getBoardListProvider.notifier).refresh();
      },
      child: ListView.builder(
          controller: scrollController,
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
              onTap: () {
                context.goNamed(
                  BoardDetailScreen.routeName,
                  pathParameters: {
                    'rid': board.id,
                  },
                );
              },
            );
          }),
    );
  }

  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(getBoardListProvider.notifier).fetchData();
    }
  }
}
