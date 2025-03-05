import 'package:ddai_community/chat/component/my_chat_bubble.dart';
import 'package:ddai_community/chat/component/other_chat_bubble.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OtherChatBubble(
              userName: 'User1',
              message: 'Hello',
            ),
            MyChatBubble(
              message: 'hihihihihihi',
            ),
          ],
        ),
      ),
    );
  }
}
