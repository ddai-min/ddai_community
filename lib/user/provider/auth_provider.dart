import 'package:ddai_community/user/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// 이메일 회원가입
final signUpWithEmailProvider =
    FutureProvider.family<User?, SignUpWithEmailParams>((ref, params) async {
  final result = await AuthRepository.signUp(
    email: params.email,
    password: params.password,
    userName: params.userName,
  );

  return result;
});
