import 'package:ddai_community/chat/component/chat_text_field.dart';
import 'package:ddai_community/chat/component/my_chat_bubble.dart';
import 'package:ddai_community/chat/component/other_chat_bubble.dart';
import 'package:ddai_community/chat/model/chat_model.dart';
import 'package:ddai_community/chat/provider/chat_provider.dart';
import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late ScrollController scrollController;
  late TextEditingController chatTextController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    chatTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final chatList = ref.watch(getChatListProvider);

    return chatList.when(
      loading: () => const Center(
        child: DefaultCircularProgressIndicator(),
      ),
      error: (error, stack) => const Center(
        child: Text('로딩 중에 오류가 발생하였습니다.'),
      ),
      data: (data) => Column(
        children: [
          Expanded(
            child: _Body(
              scrollController: scrollController,
              chatList: data,
            ),
          ),
          _Input(
            controller: chatTextController,
            onChanged: (value) {
              chatTextController.text = value;
            },
            onPressed: _onChatPressed,
          ),
        ],
      ),
    );
  }

  void _onChatPressed() {
    ref.read(
      addChatProvider(
        AddChatParams(
          content: chatTextController.text,
          userName: ref.read(userMeProvider).userName,
        ),
      ),
    );

    chatTextController.text = '';

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }
}

class _Body extends ConsumerWidget {
  final ScrollController scrollController;
  final List<ChatModel> chatList;

  const _Body({
    required this.scrollController,
    required this.chatList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      controller: scrollController,
      reverse: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: chatList.map((e) {
            if (e.userName == ref.read(userMeProvider).userName) {
              return Column(
                children: [
                  MyChatBubble(
                    message: e.content,
                  ),
                  const SizedBox(height: 10),
                ],
              );
            } else {
              return Column(
                children: [
                  OtherChatBubble(
                    userName: e.userName,
                    message: e.content,
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPressed;

  const _Input({
    required this.controller,
    required this.onChanged,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ChatTextField(
      controller: controller,
      onChanged: onChanged,
      onPressed: onPressed,
    );
  }
}
