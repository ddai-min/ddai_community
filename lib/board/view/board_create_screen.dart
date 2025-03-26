import 'package:ddai_community/board/provider/board_provider.dart';
import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BoardCreateScreen extends ConsumerStatefulWidget {
  static get routeName => 'board_create';

  const BoardCreateScreen({super.key});

  @override
  ConsumerState<BoardCreateScreen> createState() => _BoardCreateScreenState();
}

class _BoardCreateScreenState extends ConsumerState<BoardCreateScreen> {
  final formKey = GlobalKey<FormState>();

  TextEditingController titleTextController = TextEditingController();
  TextEditingController contentTextController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    titleTextController.dispose();
    contentTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '게시글 작성',
      actions: [
        TextButton(
          onPressed: _addBoard,
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
        child: Form(
          key: formKey,
          child: _Body(
            titleValidator: _boardCreateTitleValidator,
            contentValidator: _boardCreateContentValidator,
            titleTextController: titleTextController,
            contentTextController: contentTextController,
            titleTextOnChanged: (value) {
              titleTextController.text = value;
            },
            contentTextOnChanged: (value) {
              contentTextController.text = value;
            },
          ),
        ),
      ),
    );
  }

  String? _boardCreateTitleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '제목을 입력해주세요.';
    }

    return null;
  }

  String? _boardCreateContentValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '내용을 입력해주세요.';
    }

    return null;
  }

  Future<void> _addBoard() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final isCreateSuccess = await ref.read(
      addBoardProvider(
        AddBoardParams(
          title: titleTextController.text,
          content: contentTextController.text,
          userName: ref.read(userMeProvider).userName,
        ),
      ).future,
    );

    if (isCreateSuccess) {
      ref.read(getBoardListProvider.notifier).refresh();

      context.pop();
    }
  }
}

class _Body extends StatelessWidget {
  final FormFieldValidator<String> titleValidator;
  final FormFieldValidator<String> contentValidator;
  final TextEditingController titleTextController;
  final TextEditingController contentTextController;
  final ValueChanged<String> titleTextOnChanged;
  final ValueChanged<String> contentTextOnChanged;

  const _Body({
    required this.titleValidator,
    required this.contentValidator,
    required this.titleTextController,
    required this.contentTextController,
    required this.titleTextOnChanged,
    required this.contentTextOnChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextField(
          controller: titleTextController,
          validator: titleValidator,
          hintText: '제목을 입력해주세요.',
          onChanged: titleTextOnChanged,
        ),
        DefaultTextField(
          controller: contentTextController,
          validator: contentValidator,
          hintText: '내용을 입력해주세요.',
          maxLines: 20,
          onChanged: contentTextOnChanged,
        ),
      ],
    );
  }
}
