import 'package:ddai_community/board/view/board_create_screen.dart';
import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
