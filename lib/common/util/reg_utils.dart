class RegUtils {
  static bool isValidEmail({
    required String email,
  }) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  static bool isValidNickname({
    required String nickname,
  }) {
    final RegExp nicknameRegex = RegExp(
      r'^[a-zA-Z0-9가-힣]{2,12}$',
    );

    return nicknameRegex.hasMatch(nickname);
  }
}
