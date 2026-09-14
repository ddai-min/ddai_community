import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/providers/pagination_provider.dart';
import 'package:ddai_community/core/providers/session_provider.dart';
import 'package:ddai_community/features/notification/data/notification_repository.dart';
import 'package:ddai_community/features/notification/domain/notification_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_provider.g.dart';

/// [NotificationRepository] 인스턴스 제공.
@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepository();

/// 알림 목록 Notifier.
///
/// 받는 사람으로 좁히는 override 가 없는 것은 실수가 아니다. RLS 가 이미
/// 내 알림만 내려주므로 `userUid` 를 넘길 필요가 없다.
@riverpod
class NotificationList extends _$NotificationList
    with PaginationMixin<NotificationModel> {
  @override
  PaginationModel<NotificationModel> build() => initialState();

  @override
  PaginationRepository<NotificationModel> get paginationRepository =>
      ref.read(notificationRepositoryProvider);

  /// 알림 1건을 읽음 처리한다.
  ///
  /// 누른 즉시 강조를 걷어내고(낙관적) 서버에 반영한다. 실패하면 되돌린다 —
  /// 읽지 않았는데 읽은 것처럼 남으면 배지 개수와 목록이 어긋난다.
  Future<void> markAsRead(String id) async {
    final index = state.items.indexWhere((item) => item.id == id);

    if (index == -1 || state.items[index].isRead) {
      return;
    }

    final original = state.items[index];

    _replaceItem(original.asRead());

    final isSuccess = await NotificationRepository.markAsRead(searchId: id);

    if (!isSuccess) {
      _replaceItem(original);

      return;
    }

    ref.read(notificationUnreadCountProvider.notifier).refresh();
  }

  /// 안 읽은 알림을 모두 읽음 처리한다. 성공 여부를 bool 로 반환한다.
  Future<bool> markAllAsRead() async {
    final isSuccess = await NotificationRepository.markAllAsRead();

    if (isSuccess) {
      state = state.copyWith(
        items: state.items.map((item) => item.asRead()).toList(),
      );

      ref.read(notificationUnreadCountProvider.notifier).refresh();
    }

    return isSuccess;
  }

  /// 같은 id 의 항목만 갈아 끼운다.
  ///
  /// 위치(index)로 바꾸지 않는 이유는, 서버 왕복 사이에 새로고침이 끼어들어
  /// 목록이 통째로 바뀌어 있을 수 있기 때문이다.
  void _replaceItem(NotificationModel target) {
    state = state.copyWith(
      items: state.items
          .map((item) => item.id == target.id ? target : item)
          .toList(),
    );
  }
}

/// 안 읽은 알림 개수. AppBar 종 아이콘의 배지가 이 값을 그린다.
///
/// 어느 탭에 있든 살아 있어야 하므로 `keepAlive` 다.
/// Realtime 으로 내 알림 행을 구독해, 게시판을 보고 있는 중에 댓글이 달려도
/// 배지가 그 자리에서 올라간다.
@Riverpod(keepAlive: true)
class NotificationUnreadCount extends _$NotificationUnreadCount {
  @override
  Future<int> build() {
    // 로그인 유저가 바뀌면 구독도 개수도 새로 만든다. (RLS 때문에 결과가 다르다)
    final userUid = ref.watch(sessionUidProvider);

    if (userUid.isEmpty) {
      return Future.value(0);
    }

    ref.onDispose(
      NotificationRepository.subscribeMyChanges(
        userUid: userUid,
        onChanged: refresh,
      ),
    );

    return NotificationRepository.getUnreadCount();
  }

  /// 개수를 다시 센다. (알림을 읽은 뒤, 실시간 이벤트가 도착했을 때)
  Future<void> refresh() async {
    final count = await NotificationRepository.getUnreadCount();

    // 세는 사이에 로그아웃·유저 변경으로 폐기됐을 수 있다.
    if (!ref.mounted) {
      return;
    }

    state = AsyncData(count);
  }
}
