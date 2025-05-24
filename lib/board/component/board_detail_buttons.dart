import 'package:ddai_community/board/provider/board_provider.dart';
import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/component/text_field_dialog.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/user/model/report_parameter.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/auth_provider.dart';
import 'package:ddai_community/user/provider/report_provider.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BoardDeleteButton extends ConsumerStatefulWidget {
  final String boardId;

  const BoardDeleteButton({
    super.key,
    required this.boardId,
  });

  @override
  ConsumerState<BoardDeleteButton> createState() => _BoardDeleteButtonState();
}

class _BoardDeleteButtonState extends ConsumerState<BoardDeleteButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return DefaultDialog(
              titleText: '게시글 삭제',
              contentText: '정말로 삭제하시겠습니까?',
              buttonText: '삭제',
              onPressed: _deleteBoard,
            );
          },
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      child: const Text('삭제'),
    );
  }

  void _deleteBoard() async {
    final isDelete = await ref.read(
      deleteBoardProvider(widget.boardId).future,
    );

    if (isDelete) {
      ref.read(getBoardListProvider.notifier).refresh();

      context.goNamed(
        HomeTab.routeName,
      );
    }
  }
}

class BoardReportButton extends ConsumerStatefulWidget {
  final String userUid;
  final String userName;
  final String boardId;

  const BoardReportButton({
    super.key,
    required this.userUid,
    required this.userName,
    required this.boardId,
  });

  @override
  ConsumerState<BoardReportButton> createState() => _BoardReportButtonState();
}

class _BoardReportButtonState extends ConsumerState<BoardReportButton> {
  TextEditingController reportTextController = TextEditingController();

  @override
  void dispose() {
    reportTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return TextFieldDialog(
              textController: reportTextController,
              contentText: '신고 사유를 입력해주세요.',
              hintText: '신고 사유',
              buttonText: '신고',
              onPressed: () {
                _reportBoard(
                  userName: widget.userName,
                  userUid: widget.userUid,
                );
              },
            );
          },
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      child: const Text('신고'),
    );
  }

  void _reportBoard({
    required String userName,
    required String userUid,
  }) async {
    final isReportSuccess = await ref.read(
      reportProvider(
        ReportParams(
          reporterUserName: ref.read(userMeProvider).userName,
          reporterUserUid: ref.read(userMeProvider).id,
          reportedUserName: userName,
          reportedUserUid: userUid,
          reportReason: reportTextController.text,
          reportContentId: widget.boardId,
        ),
      ).future,
    );

    if (isReportSuccess) {
      reportTextController.text = '';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return DefaultDialog(
            titleText: '신고 완료',
            contentText: '신고가 완료되었습니다.',
            buttonText: '확인',
            onPressed: () {
              context.pop();
              context.pop();
            },
          );
        },
      );
    }
  }
}

class BoardBlockButton extends ConsumerStatefulWidget {
  final String userUid;

  const BoardBlockButton({
    super.key,
    required this.userUid,
  });

  @override
  ConsumerState<BoardBlockButton> createState() => _BoardBlockButtonState();
}

class _BoardBlockButtonState extends ConsumerState<BoardBlockButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return DefaultDialog(
              contentText: '작성자를 차단하시겠습니까?',
              buttonText: '차단',
              onPressed: () {
                _blockUser(
                  userMe: ref.read(userMeProvider),
                  blockUserUid: widget.userUid,
                );
              },
            );
          },
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      child: const Text('차단'),
    );
  }

  void _blockUser({
    required UserModel userMe,
    required String blockUserUid,
  }) async {
    if (userMe.isAnonymous) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return DefaultDialog(
            contentText: '로그인 후\n차단할 수 있습니다.',
            buttonText: '확인',
            onPressed: () {
              context.pop();
              context.pop();
            },
          );
        },
      );

      return;
    }

    final isBlockSuccess = await ref.read(
      blockUserProvider(
        blockUserUid,
      ).future,
    );

    if (isBlockSuccess) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return DefaultDialog(
            titleText: '차단 완료',
            contentText: '차단이 완료되었습니다.',
            buttonText: '확인',
            onPressed: () {
              ref.read(getBoardListProvider.notifier).refresh();

              context.goNamed(
                HomeTab.routeName,
              );
            },
          );
        },
      );
    }
  }
}
