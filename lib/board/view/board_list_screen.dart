import 'package:ddai_community/board/component/board_list_item.dart';
import 'package:ddai_community/board/provider/board_provider.dart';
import 'package:ddai_community/board/view/board_detail_screen.dart';
import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BoardListScreen extends ConsumerWidget {
  const BoardListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardList = ref.watch(getBoardListProvider);

    return boardList.when(
      loading: () => const Center(
        child: DefaultCircularProgressIndicator(),
      ),
      error: (error, stack) => Container(),
      data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return BoardListItem(
              title: data[index].title,
              content: data[index].content,
              onTap: () {
                context.goNamed(
                  BoardDetailScreen.routeName,
                  pathParameters: {
                    'rid': data[index].id,
                  },
                );
              },
            );
          }),
    );
  }
}
