// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [NotificationRepository] 인스턴스 제공.

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

/// [NotificationRepository] 인스턴스 제공.

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationRepository,
          NotificationRepository,
          NotificationRepository
        >
    with $Provider<NotificationRepository> {
  /// [NotificationRepository] 인스턴스 제공.
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'65ddb4ec00ee2df2d3ef0d4dca56d54588663626';

/// 알림 목록 Notifier.
///
/// 받는 사람으로 좁히는 override 가 없는 것은 실수가 아니다. RLS 가 이미
/// 내 알림만 내려주므로 `userUid` 를 넘길 필요가 없다.

@ProviderFor(NotificationList)
final notificationListProvider = NotificationListProvider._();

/// 알림 목록 Notifier.
///
/// 받는 사람으로 좁히는 override 가 없는 것은 실수가 아니다. RLS 가 이미
/// 내 알림만 내려주므로 `userUid` 를 넘길 필요가 없다.
final class NotificationListProvider
    extends
        $NotifierProvider<
          NotificationList,
          PaginationModel<NotificationModel>
        > {
  /// 알림 목록 Notifier.
  ///
  /// 받는 사람으로 좁히는 override 가 없는 것은 실수가 아니다. RLS 가 이미
  /// 내 알림만 내려주므로 `userUid` 를 넘길 필요가 없다.
  NotificationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationListHash();

  @$internal
  @override
  NotificationList create() => NotificationList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationModel<NotificationModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationModel<NotificationModel>>(
        value,
      ),
    );
  }
}

String _$notificationListHash() => r'19d553555e0e7f7fb6b86c86a508f677b1a80140';

/// 알림 목록 Notifier.
///
/// 받는 사람으로 좁히는 override 가 없는 것은 실수가 아니다. RLS 가 이미
/// 내 알림만 내려주므로 `userUid` 를 넘길 필요가 없다.

abstract class _$NotificationList
    extends $Notifier<PaginationModel<NotificationModel>> {
  PaginationModel<NotificationModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              PaginationModel<NotificationModel>,
              PaginationModel<NotificationModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                PaginationModel<NotificationModel>,
                PaginationModel<NotificationModel>
              >,
              PaginationModel<NotificationModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 안 읽은 알림 개수. AppBar 종 아이콘의 배지가 이 값을 그린다.
///
/// 어느 탭에 있든 살아 있어야 하므로 `keepAlive` 다.
/// Realtime 으로 내 알림 행을 구독해, 게시판을 보고 있는 중에 댓글이 달려도
/// 배지가 그 자리에서 올라간다.

@ProviderFor(NotificationUnreadCount)
final notificationUnreadCountProvider = NotificationUnreadCountProvider._();

/// 안 읽은 알림 개수. AppBar 종 아이콘의 배지가 이 값을 그린다.
///
/// 어느 탭에 있든 살아 있어야 하므로 `keepAlive` 다.
/// Realtime 으로 내 알림 행을 구독해, 게시판을 보고 있는 중에 댓글이 달려도
/// 배지가 그 자리에서 올라간다.
final class NotificationUnreadCountProvider
    extends $AsyncNotifierProvider<NotificationUnreadCount, int> {
  /// 안 읽은 알림 개수. AppBar 종 아이콘의 배지가 이 값을 그린다.
  ///
  /// 어느 탭에 있든 살아 있어야 하므로 `keepAlive` 다.
  /// Realtime 으로 내 알림 행을 구독해, 게시판을 보고 있는 중에 댓글이 달려도
  /// 배지가 그 자리에서 올라간다.
  NotificationUnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationUnreadCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationUnreadCountHash();

  @$internal
  @override
  NotificationUnreadCount create() => NotificationUnreadCount();
}

String _$notificationUnreadCountHash() =>
    r'd6c4d4c0ac4cee63712ce54cae5686e5f702cc8b';

/// 안 읽은 알림 개수. AppBar 종 아이콘의 배지가 이 값을 그린다.
///
/// 어느 탭에 있든 살아 있어야 하므로 `keepAlive` 다.
/// Realtime 으로 내 알림 행을 구독해, 게시판을 보고 있는 중에 댓글이 달려도
/// 배지가 그 자리에서 올라간다.

abstract class _$NotificationUnreadCount extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
