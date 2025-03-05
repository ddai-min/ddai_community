import 'package:ddai_community/board/component/board_list_item.dart';
import 'package:flutter/material.dart';

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
          ),
          BoardListItem(
            title: 'title1231231231231231231231234356456456456',
            content: 'content123123123123123123123123456456456456',
          ),
          BoardListItem(
            title: 'title',
            content: 'content',
          ),
          BoardListItem(
            title: 'title',
            content: 'content',
          ),
          BoardListItem(
            title: 'title',
            content: 'content',
          ),
          BoardListItem(
            title: 'title',
            content: 'content',
          ),
        ],
      ),
    );
  }
}
