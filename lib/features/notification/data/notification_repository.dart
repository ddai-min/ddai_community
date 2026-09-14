import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/notification/domain/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 인앱 알림(`notification` 테이블) 관련 Supabase 연산.
///
/// 목록은 [PaginationRepository] 를 그대로 탄다. **받는 사람으로 좁히는 일은
/// RLS(`notification_select_own`)가 서버에서 하므로** `userUid` 를 넘기지 않는다.
/// 차단한 유저가 남긴 알림도 같은 정책이 함께 걸러낸다.
///
/// 행을 만드는 메서드는 없다. 알림은 `comment`·`board_like` 의 INSERT 트리거만
/// 만들 수 있고, 앱에는 INSERT 권한 자체가 없다.
class NotificationRepository extends PaginationRepository<NotificationModel> {
  NotificationRepository()
    : super(
        table: TablePath.notification,
        fromJson: (data) => NotificationModel.fromJson(data),
      );

  /// 안 읽은 알림 개수. HEAD 요청이라 행 자체는 받아오지 않는다.
  ///
  /// 실패하면 0 을 돌려준다. 배지는 없어도 그만이지만, 여기서 예외가 새면
  /// 모든 화면이 공유하는 AppBar 가 깨진다.
  static Future<int> getUnreadCount() async {
    try {
      return await supabase
          .from('notification')
          .count(CountOption.exact)
          .eq('is_read', false);
    } catch (error) {
      logger.e(error);

      return 0;
    }
  }

  /// 알림 1건을 읽음 처리한다. 성공 여부를 bool 로 반환한다.
  ///
  /// 바뀐 행을 되받아 확인한다. RLS 가 막으면 오류 없이 0행이 바뀌므로,
  /// 이 확인이 없으면 실패를 성공으로 보고하게 된다.
  static Future<bool> markAsRead({
    required String searchId,
  }) async {
    try {
      final updatedRows = await supabase
          .from('notification')
          .update({'is_read': true})
          .eq('id', searchId)
          .select('id');

      return updatedRows.isNotEmpty;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 안 읽은 알림을 모두 읽음 처리한다. 성공 여부를 bool 로 반환한다.
  ///
  /// `is_read` 로 좁히는 것은 이미 읽은 행을 건드리지 않기 위해서이기도 하고,
  /// **PostgREST 가 조건 없는 UPDATE 를 거부**하기 때문이기도 하다.
  /// 어느 행이 내 것인지는 RLS 가 정한다.
  ///
  /// 안 읽은 알림이 없으면 0행이 바뀌지만 성공으로 본다 — 할 일이 없었을 뿐이다.
  /// (그래서 여기서는 `.select()` 로 되받아 확인하지 않는다)
  static Future<bool> markAllAsRead() async {
    try {
      await supabase
          .from('notification')
          .update({'is_read': true})
          .eq('is_read', false);

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 내 알림 행의 변화를 실시간 구독한다. 반환값은 **구독 해제 함수**다.
  ///
  /// payload 는 쓰지 않는다. 무슨 일이 있었는지와 무관하게 개수를 다시 센다 —
  /// insert/update/delete 를 각각 반영하려다 어긋나는 것보다 한 번 더 세는 쪽이
  /// 싸고 정확하다.
  ///
  /// `user_uid` 필터를 빼지 말 것. RLS 가 남의 행을 걸러 주기는 하지만, 필터가 없으면
  /// 테이블 전체의 변경이 서버에서 흘러나왔다가 버려진다.
  ///
  /// 구독에 실패해도 예외를 던지지 않는다. 배지가 실시간으로 안 바뀔 뿐이고,
  /// 화면을 열 때마다 개수를 다시 세므로 앱은 그대로 쓸 수 있다.
  static void Function() subscribeMyChanges({
    required String userUid,
    required void Function() onChanged,
  }) {
    final channel = supabase
        .channel('notification:$userUid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notification',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_uid',
            value: userUid,
          ),
          callback: (_) => onChanged(),
        )
        .subscribe((status, error) {
          if (error != null) {
            logger.e(error);
          }
        });

    return () {
      supabase.removeChannel(channel);
    };
  }
}
