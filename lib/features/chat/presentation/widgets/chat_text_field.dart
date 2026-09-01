import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/widgets/default_text_field.dart';
import 'package:flutter/material.dart';

/// 채팅 화면 하단의 메시지 입력 필드. (최대 100자)
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
