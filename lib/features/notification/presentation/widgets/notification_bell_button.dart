import 'package:ddai_community/features/notification/presentation/providers/notification_provider.dart';
import 'package:ddai_community/features/notification/presentation/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// AppBar 의 알림 종 아이콘. 안 읽은 개수를 배지로 얹는다.
///
/// 탭을 하나 더 만들지 않고 AppBar 에 둔 것은, 게시판·채팅·프로필 어디에 있든
/// 알림이 왔다는 사실이 보여야 하기 때문이다.
/// 개수는 [notificationUnreadCountProvider] 가 Realtime 으로 따라 올라간다.
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 아직 세는 중이거나 실패했으면 0 으로 본다. (배지를 감춘다)
    final unreadCount = ref.watch(notificationUnreadCountProvider).value ?? 0;

    return IconButton(
      onPressed: () {
        context.goNamed(NotificationScreen.routeName);
      },
      icon: Badge.count(
        count: unreadCount,
        isLabelVisible: unreadCount > 0,
        child: const Icon(Icons.notifications_none),
      ),
    );
  }
}
