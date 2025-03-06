import 'package:ddai_community/board/component/board_list_item.dart';
import 'package:ddai_community/board/view/board_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoardListScreen extends StatelessWidget {
  const BoardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BoardListItem(
            title: 'title',
            content: 'content',
            onTap: () {
              context.goNamed(
                BoardDetailScreen.routeName,
              );
            },
          ),
        ],
      ),
    );
  }
}
