import 'package:flutter/material.dart';

/// 상대방이 보낸 메시지 말풍선. (왼쪽 정렬)
///
/// [isSayAgain] 이 true 면 같은 사람이 연속으로 보낸 메시지로 보고 이름을 생략한다.
class OtherChatBubble extends StatelessWidget {
  final bool isSayAgain;
  final String userName;
  final String message;

  const OtherChatBubble({
    super.key,
    required this.isSayAgain,
    required this.userName,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSayAgain) Text(userName),
        if (!isSayAgain) const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(message),
        ),
      ],
    );
  }
}
