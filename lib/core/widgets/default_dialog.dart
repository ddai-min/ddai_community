import 'package:ddai_community/core/widgets/default_elevated_button.dart';
import 'package:flutter/material.dart';

/// 안내 문구와 확인 버튼 하나로 구성된 공통 다이얼로그.
///
/// [titleText] 를 주면 굵은 제목이 함께 렌더된다.
/// [width] 가 0 이면 화면 너비의 80% 를 사용한다.
class DefaultDialog extends StatelessWidget {
  final String? titleText;
  final String contentText;
  final String buttonText;
  final VoidCallback onPressed;
  final double width;
  final TextStyle contentTextStyle;

  const DefaultDialog({
    super.key,
    this.titleText,
    required this.contentText,
    required this.buttonText,
    required this.onPressed,
    this.width = 0,
    this.contentTextStyle = const TextStyle(
      fontSize: 16.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: width == 0 ? MediaQuery.of(context).size.width * 0.8 : width,
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (titleText != null)
                  Text(
                    titleText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (titleText != null) const SizedBox(height: 10),
                Text(
                  contentText,
                  textAlign: TextAlign.center,
                  style: contentTextStyle,
                ),
                const SizedBox(height: 20),
                DefaultElevatedButton(
                  onPressed: onPressed,
                  text: buttonText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
