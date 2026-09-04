import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/features/auth/data/auth_repository.dart';
import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_me_provider.g.dart';

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
@Riverpod(keepAlive: true)
class UserMe extends _$UserMe {
  @override
  UserModel build() {
    // Supabase.initialize 가 저장된 세션 복원까지 끝낸 뒤라 이 값은 이미 정확하다.
    final user = supabase.auth.currentUser;

    if (user == null) {
      return UserModel(
        id: '',
        userName: '',
        isAnonymous: false,
      );
    }

    // 익명/이메일 분기는 repository 가 담당한다. (표시 이름 규칙을 한곳에 둔다)
    return AuthRepository.userModelFrom(user);
  }

  /// 콜백으로 현재 상태를 변환해 갱신한다.
  void update(UserModel Function(UserModel state) cb) => state = cb(state);
}
