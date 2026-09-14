import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/default_list_placeholder.dart';
import 'package:ddai_community/features/board/presentation/screens/board_detail_screen.dart';
import 'package:ddai_community/features/notification/presentation/providers/notification_provider.dart';
import 'package:ddai_community/features/notification/presentation/widgets/notification_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 알림 목록 화면. (AppBar 의 종 아이콘에서 진입)
///
/// 내 글에 달린 댓글과 좋아요를 최신순으로 보여주고, 누르면 그 글로 이동한다.
/// 목록 자체는 게시판과 같은 커서 페이지네이션이며, **받는 사람으로 좁히는 일은
/// RLS 가 한다.**
class NotificationScreen extends ConsumerStatefulWidget {
  static String get routeName => 'notification';

  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(notificationListProvider.notifier).fetchData();
    });

    scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_listener);
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationList = ref.watch(notificationListProvider);
    final unreadCount = ref.watch(notificationUnreadCountProvider).value ?? 0;

    return DefaultLayout(
      title: '알림',
      // 목록이 스스로 스크롤한다. 안 읽음 배경도 화면 끝까지 닿아야 한다.
      isScrollable: false,
      padding: EdgeInsets.zero,
      actions: unreadCount > 0
          ? [
              TextButton(
                onPressed: _markAllAsRead,
                // AppBar 가 브랜드 색이라 테마 기본 전경색으로는 글자가 묻힌다.
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('모두 읽음'),
              ),
            ]
          : null,
      child: notificationList.items.isEmpty && notificationList.isLoading
          ? const Center(
              child: DefaultCircularProgressIndicator(),
            )
          : RefreshIndicator(
              color: primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                ref.read(notificationListProvider.notifier).refresh();
              },
              // 비었을 때도 스크롤 가능한 위젯을 두어야 당겨서 새로고침이 동작한다.
              child: notificationList.items.isEmpty
                  ? _renderPlaceholder(hasError: notificationList.hasError)
                  : ListView.separated(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemCount:
                          notificationList.items.length +
                          (notificationList.hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index == notificationList.items.length) {
                          return const Center(
                            child: DefaultCircularProgressIndicator(),
                          );
                        }

                        final notification = notificationList.items[index];

                        return NotificationListItem(
                          notification: notification,
                          onTap: () {
                            // 읽음 처리는 기다리지 않는다. 화면은 곧바로 넘어간다.
                            ref
                                .read(notificationListProvider.notifier)
                                .markAsRead(notification.id);

                            context.pushNamed(
                              BoardDetailScreen.routeName,
                              pathParameters: {
                                'id': notification.boardId,
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }

  /// 목록이 비었을 때 자리에 놓는 안내.
  ///
  /// 조회 실패와 "알림 없음" 을 구분한다. 둘 다 빈 목록으로 돌아오기 때문이다.
  Widget _renderPlaceholder({
    required bool hasError,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: DefaultListPlaceholder(
            message: hasError
                ? '알림을 불러오지 못했습니다.\n네트워크 상태를 확인해주세요.'
                : '아직 도착한 알림이 없습니다.',
            onRetry: hasError
                ? () {
                    ref.read(notificationListProvider.notifier).refresh();
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _markAllAsRead() async {
    final isSuccess = await ref
        .read(notificationListProvider.notifier)
        .markAllAsRead();

    if (isSuccess) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return DefaultDialog(
          contentText: '읽음 처리에 실패했습니다.\n잠시 후 다시 시도해주세요.',
          buttonText: '확인',
          onPressed: () {
            context.pop();
          },
        );
      },
    );
  }

  /// 스크롤이 목록 끝(200px 이내)에 도달하면 다음 페이지를 불러온다. (무한 스크롤)
  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationListProvider.notifier).fetchData();
    }
  }
}
