import 'package:ddai_community/chat/component/chat_text_field.dart';
import 'package:ddai_community/chat/component/my_chat_bubble.dart';
import 'package:ddai_community/chat/component/other_chat_bubble.dart';
import 'package:ddai_community/chat/model/chat_model.dart';
import 'package:ddai_community/chat/model/chat_parameter.dart';
import 'package:ddai_community/chat/provider/chat_provider.dart';
import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController chatTextController = TextEditingController();

  @override
  void dispose() {
    scrollController.dispose();
    chatTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatList = ref.watch(chatListProvider);

    if (chatList.items.isEmpty && chatList.isLoading) {
      return const Center(
        child: DefaultCircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _Body(
            scrollController: scrollController,
            chatList: chatList,
          ),
        ),
        _Input(
          controller: chatTextController,
          onPressed: _onChatPressed,
        ),
      ],
    );
  }

  void _onChatPressed() {
    if (chatTextController.text.isEmpty) {
      return;
    }

    ref.read(
      addChatProvider(
        AddChatParams(
          content: chatTextController.text,
          userName: ref.read(userMeProvider).userName,
          userUid: ref.read(userMeProvider).id,
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
  final PaginationModel<ChatModel> chatList;

  const _Body({
    required this.scrollController,
    required this.chatList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      controller: scrollController,
      // 최신 메시지가 하단에 오도록 리스트를 뒤집어 렌더링한다.
      reverse: true,
      itemCount: chatList.items.length,
      itemBuilder: (context, index) {
        // 바로 다음(더 이전 시각) 메시지. 같은 사람의 연속 발화인지 판단하는 데 쓴다.
        ChatModel? postChatItem;
        if (index < chatList.items.length - 1) {
          postChatItem = chatList.items[index + 1];
        }
        final chatItem = chatList.items[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 내 메시지는 오른쪽, 상대 메시지는 왼쪽 말풍선으로 표시한다.
              // (상대가 연속으로 보낸 경우 isSayAgain=true 로 이름을 생략)
              if (chatItem.userUid == ref.read(userMeProvider).id)
                MyChatBubble(message: chatItem.content)
              else
                OtherChatBubble(
                  isSayAgain: postChatItem?.userUid == chatItem.userUid,
                  userName: chatItem.userName,
                  message: chatItem.content,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPressed;

  const _Input({
    required this.controller,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ChatTextField(
      controller: controller,
      onPressed: onPressed,
    );
  }
}
