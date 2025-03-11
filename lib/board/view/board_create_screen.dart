import 'package:ddai_community/board/provider/board_provider.dart';
import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoardCreateScreen extends StatefulWidget {
  static get routeName => '/board_create';

  const BoardCreateScreen({super.key});

  @override
  State<BoardCreateScreen> createState() => _BoardCreateScreenState();
}

class _BoardCreateScreenState extends State<BoardCreateScreen> {
  late TextEditingController titleTextController;
  late TextEditingController contentTextController;

  @override
  void initState() {
    super.initState();

    titleTextController = TextEditingController();
    contentTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '게시글 작성',
      actions: [
        TextButton(
          onPressed: () async {
            final isCreateSuccess = await BoardProvider.addBoard(
              title: titleTextController.text,
              content: contentTextController.text,
              userName: 'userName',
            );

            if (isCreateSuccess) {
              context.pop();
            }
          },
          child: const Text(
            '작성',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          children: [
            DefaultTextField(
              controller: titleTextController,
              hintText: '제목을 입력해주세요.',
              onChanged: (value) {
                titleTextController.text = value;
              },
            ),
            DefaultTextField(
              controller: contentTextController,
              hintText: '내용을 입력해주세요.',
              maxLines: 20,
              onChanged: (value) {
                contentTextController.text = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
