import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

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
