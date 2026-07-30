/// 이메일 회원가입 요청 파라미터.
class SignUpWithEmailParams {
  final String email;
  final String password;
  final String userName;

  SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.userName,
  });
}
