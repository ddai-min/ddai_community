import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_me_provider.g.dart';

/// 앱 전역의 현재 로그인 유저 상태를 관리하는 Notifier.
///
/// 로그인/로그아웃/프로필 수정 시 갱신되며, [UserModel.id] 가 빈 문자열이면
/// 비로그인 상태다. 갱신은 주로 app/app.dart 의 FirebaseAuth authStateChanges
/// 리스너에서 [update] 를 통해 이루어진다. (앱 전역 상태이므로 keepAlive)
@Riverpod(keepAlive: true)
class UserMe extends _$UserMe {
  @override
  UserModel build() => UserModel(
        id: '',
        userName: '',
        isAnonymous: false,
      );

  /// 콜백으로 현재 상태를 변환해 갱신한다.
  void update(UserModel Function(UserModel state) cb) => state = cb(state);
}
