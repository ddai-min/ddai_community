// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_me_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
///
/// [UserModel.id] 가 빈 문자열이면 비로그인 상태다. 로그인·로그아웃·프로필 수정 시
/// `app/app.dart` 의 `onAuthStateChange` 리스너가 [update] 로 갱신한다.
/// (앱 전역 상태이므로 keepAlive)
///
/// **초기값은 복원된 세션에서 곧바로 만든다.** 위 리스너는 스트림이라 구독 직후가
/// 아니라 한 박자 뒤에 도착하는데, 그 사이에 이 값이 비어 있으면 세션이 멀쩡히
/// 살아 있는데도 화면은 비로그인으로 판단한다. (`HomeTab` 이 로그인 안내를 띄웠다)
/// `sessionUidProvider` 도 같은 이유로 `currentUser` 를 먼저 읽는다.

@ProviderFor(UserMe)
final userMeProvider = UserMeProvider._();

/// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
///
/// [UserModel.id] 가 빈 문자열이면 비로그인 상태다. 로그인·로그아웃·프로필 수정 시
/// `app/app.dart` 의 `onAuthStateChange` 리스너가 [update] 로 갱신한다.
/// (앱 전역 상태이므로 keepAlive)
///
/// **초기값은 복원된 세션에서 곧바로 만든다.** 위 리스너는 스트림이라 구독 직후가
/// 아니라 한 박자 뒤에 도착하는데, 그 사이에 이 값이 비어 있으면 세션이 멀쩡히
/// 살아 있는데도 화면은 비로그인으로 판단한다. (`HomeTab` 이 로그인 안내를 띄웠다)
/// `sessionUidProvider` 도 같은 이유로 `currentUser` 를 먼저 읽는다.
final class UserMeProvider extends $NotifierProvider<UserMe, UserModel> {
  /// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
  ///
  /// [UserModel.id] 가 빈 문자열이면 비로그인 상태다. 로그인·로그아웃·프로필 수정 시
  /// `app/app.dart` 의 `onAuthStateChange` 리스너가 [update] 로 갱신한다.
  /// (앱 전역 상태이므로 keepAlive)
  ///
  /// **초기값은 복원된 세션에서 곧바로 만든다.** 위 리스너는 스트림이라 구독 직후가
  /// 아니라 한 박자 뒤에 도착하는데, 그 사이에 이 값이 비어 있으면 세션이 멀쩡히
  /// 살아 있는데도 화면은 비로그인으로 판단한다. (`HomeTab` 이 로그인 안내를 띄웠다)
  /// `sessionUidProvider` 도 같은 이유로 `currentUser` 를 먼저 읽는다.
  UserMeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userMeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userMeHash();

  @$internal
  @override
  UserMe create() => UserMe();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserModel>(value),
    );
  }
}

String _$userMeHash() => r'36f555e36d4b0c552b471013ae40208796c48d6c';

/// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
///
/// [UserModel.id] 가 빈 문자열이면 비로그인 상태다. 로그인·로그아웃·프로필 수정 시
/// `app/app.dart` 의 `onAuthStateChange` 리스너가 [update] 로 갱신한다.
/// (앱 전역 상태이므로 keepAlive)
///
/// **초기값은 복원된 세션에서 곧바로 만든다.** 위 리스너는 스트림이라 구독 직후가
/// 아니라 한 박자 뒤에 도착하는데, 그 사이에 이 값이 비어 있으면 세션이 멀쩡히
/// 살아 있는데도 화면은 비로그인으로 판단한다. (`HomeTab` 이 로그인 안내를 띄웠다)
/// `sessionUidProvider` 도 같은 이유로 `currentUser` 를 먼저 읽는다.

abstract class _$UserMe extends $Notifier<UserModel> {
  UserModel build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UserModel, UserModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserModel, UserModel>,
              UserModel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
