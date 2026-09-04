import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 내가 보낸 메시지 말풍선. (오른쪽 정렬, 브랜드 색 배경)
///
/// 길게 누르면 [onLongPress] 로 삭제를 알린다. 전송 중인 임시 말풍선에는
/// null 이 들어와 눌러도 반응하지 않는다 — 서버에 지울 행이 아직 없기 때문이다.
class MyChatBubble extends StatelessWidget {
  final String message;
  final VoidCallback? onLongPress;

  const MyChatBubble({
    super.key,
    required this.message,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
