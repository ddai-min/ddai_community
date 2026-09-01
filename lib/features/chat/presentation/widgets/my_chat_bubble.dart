import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 내가 보낸 메시지 말풍선. (오른쪽 정렬, 브랜드 색 배경)
class MyChatBubble extends StatelessWidget {
  final String message;

  const MyChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
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
      ],
    );
  }
}
