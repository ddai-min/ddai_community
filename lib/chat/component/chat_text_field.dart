import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

class ChatTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onPressed;

  const ChatTextField({
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
      hintText: '메시지를 입력하세요.',
      suffixIcon: IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.send_rounded,
        ),
      ),
    );
  }
}
