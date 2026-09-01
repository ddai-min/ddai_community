import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 브랜드 색상을 기본값으로 갖는 공통 채움 버튼.
///
/// [onPressed] 가 null 이면 비활성 상태로 렌더된다.
class DefaultElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final OutlinedBorder? shape;
  final EdgeInsetsGeometry? padding;

  const DefaultElevatedButton({
    super.key,
    this.onPressed,
    required this.text,
    this.backgroundColor = primaryColor,
    this.foregroundColor = Colors.white,
    this.shape,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
      ),
      child: Text(text),
    );
  }
}
