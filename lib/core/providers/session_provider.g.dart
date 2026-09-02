// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 세션의 유저 uid. 비로그인이면 빈 문자열.
///
/// 목록 조회 결과는 RLS 때문에 **세션마다 달라진다**(차단한 유저의 글이 빠지는 등).
/// 그래서 로그인 유저가 바뀌면 목록을 처음부터 다시 만들어야 하고,
/// [PaginationMixin.initialState] 가 이 provider 를 watch 해 그 시점을 잡는다.
///
/// `features/user` 의 `userMeProvider` 도 같은 정보를 갖고 있지만, core 가 feature 를
/// 참조하지 않도록(의존 방향은 `features → core`) core 안에 따로 둔다.

@ProviderFor(SessionUid)
final sessionUidProvider = SessionUidProvider._();

/// 현재 세션의 유저 uid. 비로그인이면 빈 문자열.
///
/// 목록 조회 결과는 RLS 때문에 **세션마다 달라진다**(차단한 유저의 글이 빠지는 등).
/// 그래서 로그인 유저가 바뀌면 목록을 처음부터 다시 만들어야 하고,
/// [PaginationMixin.initialState] 가 이 provider 를 watch 해 그 시점을 잡는다.
///
/// `features/user` 의 `userMeProvider` 도 같은 정보를 갖고 있지만, core 가 feature 를
/// 참조하지 않도록(의존 방향은 `features → core`) core 안에 따로 둔다.
final class SessionUidProvider extends $NotifierProvider<SessionUid, String> {
  /// 현재 세션의 유저 uid. 비로그인이면 빈 문자열.
  ///
  /// 목록 조회 결과는 RLS 때문에 **세션마다 달라진다**(차단한 유저의 글이 빠지는 등).
  /// 그래서 로그인 유저가 바뀌면 목록을 처음부터 다시 만들어야 하고,
  /// [PaginationMixin.initialState] 가 이 provider 를 watch 해 그 시점을 잡는다.
  ///
  /// `features/user` 의 `userMeProvider` 도 같은 정보를 갖고 있지만, core 가 feature 를
  /// 참조하지 않도록(의존 방향은 `features → core`) core 안에 따로 둔다.
  SessionUidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionUidProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionUidHash();

  @$internal
  @override
  SessionUid create() => SessionUid();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$sessionUidHash() => r'977384f1a3ac42cbebe09d1fd80648e68e09c49c';

/// 현재 세션의 유저 uid. 비로그인이면 빈 문자열.
///
/// 목록 조회 결과는 RLS 때문에 **세션마다 달라진다**(차단한 유저의 글이 빠지는 등).
/// 그래서 로그인 유저가 바뀌면 목록을 처음부터 다시 만들어야 하고,
/// [PaginationMixin.initialState] 가 이 provider 를 watch 해 그 시점을 잡는다.
///
/// `features/user` 의 `userMeProvider` 도 같은 정보를 갖고 있지만, core 가 feature 를
/// 참조하지 않도록(의존 방향은 `features → core`) core 안에 따로 둔다.

abstract class _$SessionUid extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
