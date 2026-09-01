/// 정규식 기반 입력값 유효성 검사 유틸.
class RegUtils {
  /// 이메일 형식이 올바른지 검사한다.
  static bool isValidEmail({
    required String email,
  }) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  /// 닉네임이 한글·영문·숫자로만 이루어진 2~12자인지 검사한다.
  static bool isValidNickname({
    required String nickname,
  }) {
    final RegExp nicknameRegex = RegExp(
      r'^[a-zA-Z0-9가-힣]{2,12}$',
    );

    return nicknameRegex.hasMatch(nickname);
  }

  /// 비밀번호에 영소문자·숫자·특수문자가 모두 포함되어 있는지 검사한다.
  ///
  /// 길이 조건은 호출하는 validator 에서 별도로 확인한다.
  static bool isValidPassword({
    required String password,
  }) {
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    if (!hasLowercase || !hasNumber || !hasSpecialChar) {
      return false;
    }

    return true;
  }
}
