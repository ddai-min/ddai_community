/// 이메일 회원가입 요청 파라미터.
class SignUpWithEmailParams {
  final String email;
  final String password;
  final String userName;

  /// CAPTCHA 토큰. 화면이 `issueCaptchaToken` 으로 받아 실어 보낸다.
  ///
  /// 발급은 웹뷰가 필요해 presentation 계층에서만 할 수 있다. 토큰은 1회용이라
  /// 요청마다 새로 만들며, CAPTCHA 를 안 쓰는 설정에서는 null 이 실려 서버가 무시한다.
  final String? captchaToken;

  SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.userName,
    this.captchaToken,
  });
}
