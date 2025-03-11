import 'package:ddai_community/board/component/board_list_item.dart';
import 'package:ddai_community/board/provider/board_provider.dart';
import 'package:ddai_community/board/view/board_detail_screen.dart';
import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:ddai_community/common/layout/future_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoardListScreen extends StatelessWidget {
  const BoardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureLayout(
      future: BoardProvider.getBoardList(),
      loadingDataWidget: const Center(
        child: DefaultCircularProgressIndicator(),
      ),
      nullDataWidget: Container(),
      widget: (snapshot) => ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return BoardListItem(
            title: snapshot.data![index].title,
            content: snapshot.data![index].content,
            onTap: () {
              context.goNamed(
                BoardDetailScreen.routeName,
                pathParameters: {
                  'rid': snapshot.data![index].id,
                },
              );
            },
          );
        },
      ),
    );
  }
}
