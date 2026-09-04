import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/default_text_field.dart';
import 'package:ddai_community/features/board/domain/board_parameter.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 게시글 작성·수정 화면.
///
/// [boardId] 가 있으면 수정, 없으면 작성이다. 입력 폼과 검증이 완전히 같아서
/// 화면을 나누지 않았다.
/// 성공하면 목록([boardListProvider])을 새로고침하고 이전 화면으로 돌아간다.
class BoardCreateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'board_create';

  /// 수정 모드 라우트. 작성과 화면은 같고 경로만 다르다.
  static String get editRouteName => 'board_edit';

  /// 수정할 게시글 id. null 이면 새 글 작성이다.
  final String? boardId;

  const BoardCreateScreen({
    super.key,
    this.boardId,
  });

  @override
  ConsumerState<BoardCreateScreen> createState() => _BoardCreateScreenState();
}

class _BoardCreateScreenState extends ConsumerState<BoardCreateScreen> {
  final formKey = GlobalKey<FormState>();

  TextEditingController titleTextController = TextEditingController();
  TextEditingController contentTextController = TextEditingController();

  /// 수정 모드에서 기존 값을 한 번만 채우기 위한 표시.
  /// (이 값이 없으면 사용자가 고친 내용이 매 빌드마다 되돌아간다)
  bool isPrefilled = false;

  @override
  void dispose() {
    super.dispose();

    titleTextController.dispose();
    contentTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardId = widget.boardId;

    if (boardId != null && !isPrefilled) {
      // 상세 화면이 이미 불러 둔 값이라 대개 곧바로 들어온다.
      final board = ref.watch(getBoardProvider(boardId)).value;

      if (board != null) {
        titleTextController.text = board.title;
        contentTextController.text = board.content;
        isPrefilled = true;
      }
    }

    return DefaultLayout(
      title: boardId == null ? '게시글 작성' : '게시글 수정',
      actions: [
        TextButton(
          onPressed: _submit,
          child: Text(
            boardId == null ? '작성' : '수정',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
      child: Form(
        key: formKey,
        child: _Body(
          titleValidator: _boardCreateTitleValidator,
          contentValidator: _boardCreateContentValidator,
          titleTextController: titleTextController,
          contentTextController: contentTextController,
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

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final boardId = widget.boardId;

    final isSuccess = boardId == null
        ? await ref.read(
            addBoardProvider(
              AddBoardParams(
                title: titleTextController.text,
                content: contentTextController.text,
                userName: ref.read(userMeProvider).userName,
                userUid: ref.read(userMeProvider).id,
              ),
            ).future,
          )
        : await ref.read(
            updateBoardProvider(
              UpdateBoardParams(
                searchId: boardId,
                title: titleTextController.text,
                content: contentTextController.text,
              ),
            ).future,
          );

    if (!isSuccess) {
      return;
    }

    ref.read(boardListProvider.notifier).refresh();

    // 수정한 글은 상세 화면이 다시 읽어야 바뀐 내용이 보인다.
    if (boardId != null) {
      ref.invalidate(getBoardProvider(boardId));
    }

    context.pop();
  }
}

class _Body extends StatelessWidget {
  final FormFieldValidator<String> titleValidator;
  final FormFieldValidator<String> contentValidator;
  final TextEditingController titleTextController;
  final TextEditingController contentTextController;

  const _Body({
    required this.titleValidator,
    required this.contentValidator,
    required this.titleTextController,
    required this.contentTextController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextField(
          controller: titleTextController,
          validator: titleValidator,
          hintText: '제목을 입력해주세요.',
          maxLength: 30,
        ),
        DefaultTextField(
          controller: contentTextController,
          validator: contentValidator,
          hintText: '내용을 입력해주세요.',
          maxLines: 20,
        ),
      ],
    );
  }
}
