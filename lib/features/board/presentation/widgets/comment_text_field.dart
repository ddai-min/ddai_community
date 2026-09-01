import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/widgets/default_text_field.dart';
import 'package:flutter/material.dart';

/// 게시글 상세 화면 하단의 댓글 입력 필드. (최대 100자)
class CommentTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onPressed;

  const CommentTextField({
    super.key,
    this.controller,
    this.onChanged,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextField(
      controller: controller,
      onChanged: onChanged,
      padding: 0,
      maxLength: 100,
      border: const UnderlineInputBorder(),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: primaryColor,
        ),
      ),
      hintText: '댓글 작성',
      suffixIcon: IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.send_rounded,
        ),
      ),
    );
  }
}
