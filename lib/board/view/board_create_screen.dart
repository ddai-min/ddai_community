import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:flutter/material.dart';

class BoardCreateScreen extends StatelessWidget {
  static get routeName => '/board_create';

  const BoardCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '게시글 작성',
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
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
              hintText: '제목을 입력해주세요.',
            ),
            DefaultTextField(
              hintText: '내용을 입력해주세요.',
              maxLines: 20,
            ),
          ],
        ),
      ),
    );
  }
}
