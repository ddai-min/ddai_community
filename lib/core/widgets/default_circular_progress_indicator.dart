import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 브랜드 색상이 기본값인 공통 로딩 인디케이터.
class DefaultCircularProgressIndicator extends StatelessWidget {
  final Color? color;

  const DefaultCircularProgressIndicator({
    super.key,
    this.color = primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
    );
  }
}
