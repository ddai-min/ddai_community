import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/board/presentation/screens/board_create_screen.dart';
import 'package:ddai_community/features/chat/presentation/providers/chat_provider.dart';
import 'package:ddai_community/features/home/presentation/screens/home_tab.dart';
import 'package:ddai_community/features/user/domain/report_parameter.dart';
import 'package:ddai_community/features/user/presentation/widgets/report_block_actions.dart';
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

/// 게시글 수정 버튼. (작성자 본인에게만 노출)
///
/// 작성 화면을 수정 모드로 연다. `goNamed` 가 아니라 `pushNamed` 라야
/// 수정을 마치고 상세 화면으로 되돌아온다.
class BoardEditButton extends StatelessWidget {
  final String boardId;

  const BoardEditButton({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.pushNamed(
          BoardCreateScreen.editRouteName,
          pathParameters: {
            'id': boardId,
          },
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      child: const Text('수정'),
    );
  }
}

/// 게시글 신고 버튼. (작성자 본인이 아닐 때 노출)
///
/// 실제 동작은 [showReportDialog] 가 맡는다. 채팅·댓글의 신고와 같은 구현이다.
class BoardReportButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () {
        showReportDialog(
          context: context,
          ref: ref,
          contentType: ReportContentType.board,
          contentId: boardId,
          userUid: userUid,
          userName: userName,
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      child: const Text('신고'),
    );
  }
}

/// 작성자 차단 버튼. (작성자 본인이 아닐 때 노출)
///
/// 차단하면 이후 목록 조회에서 RLS(`is_blocked()`)가 그 유저의 글을 제외한다.
/// 이미 받아 둔 목록에는 반영되지 않으므로 차단 후 목록을 다시 받는다.
class BoardBlockButton extends ConsumerWidget {
  final String userUid;
  final String userName;

  const BoardBlockButton({
    super.key,
    required this.userUid,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () {
        showBlockDialog(
          context: context,
          ref: ref,
          userUid: userUid,
          userName: userName,
          onBlocked: () {
            ref.read(boardListProvider.notifier).refresh();
            // 채팅은 구독을 다시 맺어야 이전 메시지까지 새 판정으로 받아온다.
            ref.invalidate(chatListProvider);

            context.goNamed(
              HomeTab.routeName,
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
}
