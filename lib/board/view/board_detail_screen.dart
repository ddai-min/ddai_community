import 'package:ddai_community/board/component/comment_list_item.dart';
import 'package:ddai_community/board/component/comment_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:flutter/material.dart';

class BoardDetailScreen extends StatefulWidget {
  static get routeName => '/board_detail';

  const BoardDetailScreen({super.key});

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  List<String> userNames = ['user1', 'user2', 'user3'];
  List<String> contents = ['content1', 'content2', 'content3'];

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: 'title',
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              const _Writing(
                title: 'title',
                content: 'content',
              ),
              const SizedBox(height: 16.0),
              CommentTextField(
                onPressed: () {},
              ),
              _CommentList(
                userNames: userNames,
                contents: contents,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Writing extends StatelessWidget {
  final String title;
  final String content;

  const _Writing({
    required this.title,
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

/// TODO: 추후 Model 변경
class _CommentList extends StatelessWidget {
  final List<String> userNames;
  final List<String> contents;

  const _CommentList({
    required this.userNames,
    required this.contents,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> commentList = List.generate(
      userNames.length,
      (int index) => CommentListItem(
        userName: userNames[index],
        content: contents[index],
      ),
    );

    return Column(
      children: commentList,
    );
  }
}
