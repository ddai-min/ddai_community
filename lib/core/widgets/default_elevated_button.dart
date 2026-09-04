import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 브랜드 색상을 기본값으로 갖는 공통 채움 버튼.
///
/// [onPressed] 가 null 이면 비활성 상태로 렌더된다.
///
/// 모서리 둥글기는 여기서 정하지 않는다. [shape] 를 비워 두면
/// `AppTheme.borderRadius` 를 따라 다이얼로그와 같은 값으로 그려진다.
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
        padding: padding ?? EdgeInsets.symmetric(vertical: 14),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        // null 이면 `styleFrom` 이 값을 비워 둬서 테마의 모양이 적용된다.
        shape: shape,
      ),
      child: Text(text),
    );
  }
}
