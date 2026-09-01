import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 브랜드 색상 글자만으로 구성된 공통 텍스트 버튼.
class DefaultTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const DefaultTextButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
      child: Text(text),
    );
  }
}
