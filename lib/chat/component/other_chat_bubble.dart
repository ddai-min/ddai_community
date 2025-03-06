import 'package:ddai_community/common/component/default_avatar.dart';
import 'package:flutter/material.dart';

class OtherChatBubble extends StatelessWidget {
  final Image? image;
  final String userName;
  final String message;

  const OtherChatBubble({
    super.key,
    required this.userName,
    required this.message,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DefaultAvatar(
          image: image,
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName),
            const SizedBox(height: 5),
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
        ),
      ],
    );
  }
}
