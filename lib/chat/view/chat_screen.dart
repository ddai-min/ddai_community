import 'package:ddai_community/chat/component/chat_text_field.dart';
import 'package:ddai_community/chat/component/my_chat_bubble.dart';
import 'package:ddai_community/chat/component/other_chat_bubble.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: _Body(),
        ),
        _Input(
          onPressed: _onChatPressed,
        ),
      ],
    );
  }

  void _onChatPressed() {}
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
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

class _Input extends StatelessWidget {
  final VoidCallback onPressed;

  const _Input({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ChatTextField(
      onPressed: onPressed,
    );
  }
}
