// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_me_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
///
/// 로그인/로그아웃/프로필 수정 시 갱신되며, [UserModel.id] 가 빈 문자열이면
/// 비로그인 상태다. 갱신은 주로 app/app.dart 의 FirebaseAuth authStateChanges
/// 리스너에서 [update] 를 통해 이루어진다. (앱 전역 상태이므로 keepAlive)

@ProviderFor(UserMe)
final userMeProvider = UserMeProvider._();

/// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
///
/// 로그인/로그아웃/프로필 수정 시 갱신되며, [UserModel.id] 가 빈 문자열이면
/// 비로그인 상태다. 갱신은 주로 app/app.dart 의 FirebaseAuth authStateChanges
/// 리스너에서 [update] 를 통해 이루어진다. (앱 전역 상태이므로 keepAlive)
final class UserMeProvider extends $NotifierProvider<UserMe, UserModel> {
  /// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
  ///
  /// 로그인/로그아웃/프로필 수정 시 갱신되며, [UserModel.id] 가 빈 문자열이면
  /// 비로그인 상태다. 갱신은 주로 app/app.dart 의 FirebaseAuth authStateChanges
  /// 리스너에서 [update] 를 통해 이루어진다. (앱 전역 상태이므로 keepAlive)
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

String _$userMeHash() => r'db65fe7379dd63239fccb96c026bb0a638465b60';

/// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
///
/// 로그인/로그아웃/프로필 수정 시 갱신되며, [UserModel.id] 가 빈 문자열이면
/// 비로그인 상태다. 갱신은 주로 app/app.dart 의 FirebaseAuth authStateChanges
/// 리스너에서 [update] 를 통해 이루어진다. (앱 전역 상태이므로 keepAlive)

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
