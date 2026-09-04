import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/features/chat/domain/chat_model.dart';
import 'package:ddai_community/features/chat/presentation/providers/chat_provider.dart';
import 'package:ddai_community/features/chat/presentation/widgets/chat_text_field.dart';
import 'package:ddai_community/features/chat/presentation/widgets/my_chat_bubble.dart';
import 'package:ddai_community/features/chat/presentation/widgets/other_chat_bubble.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 전체 공개 실시간 채팅 화면. ([HomeTab] 의 두 번째 탭)
///
/// Supabase Realtime 스트림([PaginationMixin.subscribeStream])으로 메시지를 실시간 수신하며,
/// 최신 메시지가 아래에 오도록 목록을 뒤집어(`reverse`) 렌더한다.
///
/// 전송한 메시지는 서버 왕복을 기다리지 않고 곧바로 그려진다.
/// ([ChatList.sendChat] — 낙관적 렌더링)
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

  void _onChatPressed() async {
    if (chatTextController.text.isEmpty) {
      return;
    }

    final userMe = ref.read(userMeProvider);

    // 임시 말풍선이 이 호출 안에서 곧바로 그려진다. (await 이전까지는 동기 실행)
    final sending = ref
        .read(chatListProvider.notifier)
        .sendChat(
          content: chatTextController.text,
          userName: userMe.userName,
          userUid: userMe.id,
        );

    chatTextController.text = '';

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

    // 실패하면 임시 말풍선이 사라지므로, 왜 사라졌는지 알려준다.
    if (!await sending && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('메시지를 보내지 못했습니다.'),
        ),
      );
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
    // itemBuilder 는 build 가 아니라 레이아웃 중에 불리므로 여기서 미리 구독한다.
    // 늦게 채워지면 내 메시지가 남의 말풍선으로 그려진 채 남는다.
    final myUid = ref.watch(userMeProvider).id;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        controller: scrollController,
        clipBehavior: Clip.none,
        // 최신 메시지가 하단에 오도록 리스트를 뒤집어 렌더링한다.
        reverse: true,
        itemCount: chatList.items.length,
        itemBuilder: (context, index) {
          // 바로 다음(더 이전 시각) 메시지. 뒤집어 그리므로 화면에서는 **바로 위**에 온다.
          // 같은 사람의 연속 발화인지 판단하는 데 쓴다.
          ChatModel? postChatItem;
          if (index < chatList.items.length - 1) {
            postChatItem = chatList.items[index + 1];
          }
          final chatItem = chatList.items[index];
          final isSayAgain = postChatItem?.userUid == chatItem.userUid;

          return Padding(
            // 간격을 위쪽에만 주어 이웃한 항목의 여백이 더해지지 않게 한다.
            // 같은 사람이 연달아 말한 경우 한 덩어리로 보이도록 좁힌다.
            padding: EdgeInsets.only(top: isSayAgain ? 4 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 내 메시지는 오른쪽, 상대 메시지는 왼쪽 말풍선으로 표시한다.
                // (상대가 연속으로 보낸 경우 isSayAgain=true 로 이름을 생략)
                if (chatItem.userUid == myUid)
                  MyChatBubble(
                    message: chatItem.content,
                    // 아직 전송 중인 말풍선은 서버에 지울 행이 없다.
                    onLongPress: ChatList.isPending(chatItem.id)
                        ? null
                        : () {
                            _confirmDelete(
                              context: context,
                              ref: ref,
                              chatId: chatItem.id,
                            );
                          },
                  )
                else
                  OtherChatBubble(
                    isSayAgain: isSayAgain,
                    userName: chatItem.userName,
                    message: chatItem.content,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete({
    required BuildContext context,
    required WidgetRef ref,
    required String chatId,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return DefaultDialog(
          titleText: '메시지 삭제',
          contentText: '이 메시지를 삭제하시겠습니까?',
          buttonText: '삭제',
          onPressed: () {
            dialogContext.pop();

            _deleteChat(
              context: context,
              ref: ref,
              chatId: chatId,
            );
          },
        );
      },
    );
  }

  /// 목록에서 말풍선이 걷히는 것은 실시간 스트림이 처리한다. (여기서 지우지 않는다)
  void _deleteChat({
    required BuildContext context,
    required WidgetRef ref,
    required String chatId,
  }) async {
    final isDelete = await ref.read(
      deleteChatProvider(chatId).future,
    );

    if (isDelete) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return DefaultDialog(
          contentText: '메시지를 삭제하지 못했습니다.\n잠시 후 다시 시도해주세요.',
          buttonText: '확인',
          onPressed: () {
            dialogContext.pop();
          },
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
