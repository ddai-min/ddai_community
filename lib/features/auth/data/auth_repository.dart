import 'package:ddai_community/core/data/captcha_repository.dart';
import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/utils/data_utils.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/auth/domain/auth_parameter.dart';
import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 앱에서 개별적으로 처리하는 Supabase 인증 예외 코드 모음.
///
/// 문자열 [code] 는 Supabase Auth 가 `AuthException.code` 로 내려주는 값이며,
/// 그 외의 예외는 모두 [unknownError] 로 취급한다.
/// (전체 목록: https://supabase.com/docs/guides/auth/debugging/error-codes)
enum AuthExceptionCode {
  emailAlreadyInUse('user_already_exists'),
  weakPassword('weak_password'),
  invalidCredential('invalid_credentials'),

  /// 대시보드의 "Confirm email" 이 켜져 있어 가입 직후 세션이 발급되지 않은 상태.
  /// 유저는 생성됐지만 메일의 링크를 눌러야 로그인할 수 있다.
  emailNotConfirmed('email_not_confirmed'),

  /// Authentication → Providers 에서 익명 로그인이 꺼져 있는 경우.
  anonymousDisabled('anonymous_provider_disabled'),
  noUser('session_not_found'),
  tooManyRequests('over_request_rate_limit'),

  /// Supabase 의 CAPTCHA 보호가 켜졌는데 토큰이 없거나 검증에 실패한 경우.
  /// 앱이 토큰을 못 만들었을 때(네트워크·WebView 문제)도 여기로 온다.
  captchaFailed('captcha_failed'),
  unknownError('unknown_error');

  final String code;

  const AuthExceptionCode(
    this.code,
  );
}

/// 인증 연산 결과.
///
/// 성공 시 [user] 가, 실패 시 [errorCode] 가 채워진다.
/// SDK 의 `User` 대신 앱 모델([UserModel])을 담아 화면이 Supabase 타입에 의존하지 않게 한다.
class AuthResult {
  final UserModel? user;
  final AuthExceptionCode? errorCode;

  AuthResult({
    this.user,
    this.errorCode,
  });

  /// 인증 성공 여부. ([user] 존재 여부로 판단)
  bool get isSuccess => user != null;
}

/// Supabase 인증 및 계정 관련 연산.
///
/// 가입·로그인·익명 로그인 세 경로는 [CaptchaRepository] 로 받은 CAPTCHA 토큰을
/// 함께 보낸다. 토큰은 발급 시점부터 유효기간이 짧고 1회용이라 호출 직전에 만들며,
/// CAPTCHA 를 안 쓰는 설정에서는 `null` 이 실려 서버가 무시한다.
class AuthRepository {
  /// Supabase 의 `User` 를 앱 모델로 변환한다.
  ///
  /// 표시 이름은 익명이면 uid 기반으로 생성하고([DataUtils.setAnonymousName]),
  /// 이메일 유저면 회원가입 때 넣은 `user_metadata.user_name` 을 쓴다.
  /// 이 규칙은 DB 트리거 `handle_new_user` 가 `profile.user_name` 을 채우는 규칙과 같아야 한다.
  /// `app/app.dart` 의 인증 상태 리스너도 이 메서드를 공유한다.
  static UserModel userModelFrom(User user) {
    if (user.isAnonymous) {
      return UserModel(
        id: user.id,
        userName: DataUtils.setAnonymousName(
          uid: user.id,
        ),
        isAnonymous: true,
      );
    }

    return UserModel(
      id: user.id,
      userName: user.userMetadata?['user_name'] as String? ?? user.email ?? '',
      isAnonymous: false,
      email: user.email,
    );
  }

  /// 이메일/비밀번호로 회원가입한다.
  ///
  /// `profile` 행은 DB 트리거(`handle_new_user`)가 자동 생성하므로 여기서 만들지 않는다.
  /// 표시 이름은 `data` 로 넘겨 `user_metadata` 에 저장되고, 트리거가 그 값을 읽어간다.
  static Future<AuthResult> signUp({
    required SignUpWithEmailParams signUpWithEmailParams,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: signUpWithEmailParams.email,
        password: signUpWithEmailParams.password,
        data: {
          'user_name': signUpWithEmailParams.userName,
        },
        captchaToken: await CaptchaRepository.issueToken(),
      );

      final user = response.user;

      if (user == null) {
        return AuthResult(
          errorCode: AuthExceptionCode.unknownError,
        );
      }

      // "Confirm email" 이 켜져 있으면 유저만 만들어지고 세션은 발급되지 않는다.
      // 이 경우 곧바로 로그인 상태가 아니므로 화면이 메일 인증을 안내해야 한다.
      if (response.session == null) {
        return AuthResult(
          errorCode: AuthExceptionCode.emailNotConfirmed,
        );
      }

      return AuthResult(
        user: userModelFrom(user),
      );
    } catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: _mapException(error),
      );
    }
  }

  /// 이메일/비밀번호로 로그인한다.
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
        captchaToken: await CaptchaRepository.issueToken(),
      );

      final user = response.user;

      if (user == null) {
        return AuthResult(
          errorCode: AuthExceptionCode.noUser,
        );
      }

      return AuthResult(
        user: userModelFrom(user),
      );
    } catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: _mapException(error),
      );
    }
  }

  /// 익명으로 로그인한다. (회원가입 없이 둘러보기)
  ///
  /// 익명 가입은 기본적으로 IP 당 시간당 30회로 제한되며, 초과 시
  /// [AuthExceptionCode.tooManyRequests] 를 반환한다.
  static Future<AuthResult> loginAnonymous() async {
    try {
      final response = await supabase.auth.signInAnonymously(
        captchaToken: await CaptchaRepository.issueToken(),
      );

      final user = response.user;

      if (user == null) {
        return AuthResult(
          errorCode: AuthExceptionCode.unknownError,
        );
      }

      return AuthResult(
        user: userModelFrom(user),
      );
    } catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: _mapException(error),
      );
    }
  }

  /// 로그아웃한다. 저장된 세션도 함께 지워진다.
  static Future<bool> logout() async {
    try {
      await supabase.auth.signOut();

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 표시 이름을 변경한다.
  ///
  /// `user_metadata` 와 `profile` 두 곳을 함께 갱신한다. 세션(JWT)에는 `user_metadata` 가
  /// 실려 화면이 그 값을 읽고, 게시글·댓글 조인은 `profile` 을 읽기 때문에
  /// 한쪽만 바꾸면 표시 이름이 화면마다 달라진다.
  static Future<bool> updateUserName({
    required String userName,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return false;
      }

      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'user_name': userName,
          },
        ),
      );

      await supabase
          .from('profile')
          .update({
            'user_name': userName,
          })
          .eq('id', user.id);

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// 현재 계정을 삭제한다.
  ///
  /// 클라이언트는 계정을 지울 수 없으므로(`auth.admin` 은 secret 키 전용)
  /// 비밀번호 재확인과 삭제를 모두 Edge Function `delete-account` 가 처리한다.
  /// 비밀번호가 틀리면 [AuthExceptionCode.invalidCredential] 을 반환한다.
  /// (`profile` · `board` · `chat` 등 연관 행은 FK CASCADE 로 함께 삭제된다)
  static Future<AuthResult> deleteUser({
    required String password,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return AuthResult(
        errorCode: AuthExceptionCode.noUser,
      );
    }

    // 삭제 후에는 세션이 사라지므로 반환할 모델을 미리 만들어 둔다.
    final deletedUser = userModelFrom(user);

    try {
      await supabase.functions.invoke(
        'delete-account',
        body: {
          'password': password,
        },
      );
    } on FunctionException catch (error) {
      logger.e(error);

      // Edge Function 은 실패 사유를 본문의 code 로 내려준다.
      final details = error.details;
      final code = details is Map ? details['code'] as String? : null;

      return AuthResult(
        errorCode: code == AuthExceptionCode.invalidCredential.code
            ? AuthExceptionCode.invalidCredential
            : AuthExceptionCode.unknownError,
      );
    } catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: _mapException(error),
      );
    }

    // 계정은 이미 지워졌다. 남은 로컬 세션 정리에 실패하더라도 결과를 뒤집지 않도록 분리한다.
    await logout();

    return AuthResult(
      user: deletedUser,
    );
  }

  /// 특정 유저를 차단한다. (`block_user` 에 기록)
  ///
  /// 차단된 유저의 글은 이후 목록 조회에서 제외된다. Firestore 때와 달리
  /// 클라이언트가 거르지 않고 RLS 정책(`is_blocked()`)이 서버에서 강제한다.
  /// 이미 차단한 유저를 다시 차단해도 실패하지 않도록 upsert 를 쓴다.
  static Future<bool> blockUser({
    required String blockUserUid,
  }) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return false;
      }

      await supabase.from('block_user').upsert({
        'blocker_uid': user.id,
        'blocked_uid': blockUserUid,
      });

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }

  /// Supabase 예외를 앱이 개별 처리하는 코드로 매핑한다.
  ///
  /// 사용자에게 다르게 안내해야 하는 코드만 추리고 나머지는 [AuthExceptionCode.unknownError] 로 묶는다.
  static AuthExceptionCode _mapException(Object error) {
    if (error is! AuthException) {
      return AuthExceptionCode.unknownError;
    }

    return switch (error.code) {
      'user_already_exists' ||
      'email_exists' => AuthExceptionCode.emailAlreadyInUse,
      'weak_password' => AuthExceptionCode.weakPassword,
      'invalid_credentials' => AuthExceptionCode.invalidCredential,
      'email_not_confirmed' => AuthExceptionCode.emailNotConfirmed,
      'anonymous_provider_disabled' => AuthExceptionCode.anonymousDisabled,
      'session_not_found' || 'session_missing' => AuthExceptionCode.noUser,
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' => AuthExceptionCode.tooManyRequests,
      'captcha_failed' => AuthExceptionCode.captchaFailed,
      _ => AuthExceptionCode.unknownError,
    };
  }
}
