import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/text_field_dialog.dart';
import 'package:ddai_community/features/auth/presentation/providers/auth_provider.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/home/presentation/screens/home_tab.dart';
import 'package:ddai_community/features/user/domain/report_parameter.dart';
import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:ddai_community/features/user/presentation/providers/report_provider.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 게시글 삭제 버튼. (작성자 본인에게만 노출)
///
/// 확인 다이얼로그를 거쳐 삭제한 뒤 목록을 새로고침하고 홈으로 이동한다.
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
      ref.read(boardListProvider.notifier).refresh();

      context.goNamed(
        HomeTab.routeName,
      );
    }
  }
}

/// 게시글 신고 버튼. (작성자 본인이 아닐 때 노출)
///
/// 신고 사유를 입력받아 `report` 컬렉션에 기록한다.
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

/// 작성자 차단 버튼. (작성자 본인이 아닐 때 노출)
///
/// 차단하면 `user/{uid}/blockUser` 에 기록되어 이후 목록 조회에서 해당 유저의 글이 제외된다.
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
              ref.read(boardListProvider.notifier).refresh();

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
