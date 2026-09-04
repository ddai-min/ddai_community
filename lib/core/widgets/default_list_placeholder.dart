import 'package:ddai_community/core/widgets/default_text_button.dart';
import 'package:flutter/material.dart';

/// 목록이 비었거나 불러오지 못했을 때 그 자리에 놓는 안내.
///
/// 이 위젯이 없을 때는 두 경우가 **똑같이 흰 화면**으로 보였다.
/// repository 가 예외를 삼키고 빈 목록을 돌려주는 규칙이라, 네트워크가 끊긴 것과
/// 글이 하나도 없는 것을 사용자가 구분할 수 없었다.
///
/// [onRetry] 를 주면 다시 시도 버튼이 함께 렌더된다. (오류일 때만 준다)
class DefaultListPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DefaultListPlaceholder({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.grey[600],
            ),
          ),
          if (onRetry != null)
            DefaultTextButton(
              onPressed: onRetry!,
              text: '다시 시도',
            ),
        ],
      ),
    );
  }
}
