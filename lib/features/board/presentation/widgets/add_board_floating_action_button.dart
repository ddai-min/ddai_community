import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/features/board/presentation/screens/board_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 게시판 탭에서만 노출되는 글쓰기 플로팅 버튼.
///
/// 탭하면 [BoardCreateScreen] 으로 이동한다.
class AddBoardFloatingActionButton extends StatelessWidget {
  const AddBoardFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: Colors.white,
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      elevation: 0,
      onPressed: () {
        context.goNamed(
          BoardCreateScreen.routeName,
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
