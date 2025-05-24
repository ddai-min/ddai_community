import 'package:ddai_community/user/model/auth_parameter.dart';
import 'package:ddai_community/user/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 이메일 회원가입
final signUpWithEmailProvider = FutureProvider.family
    .autoDispose<AuthResult, SignUpWithEmailParams>((ref, params) async {
  final result = await AuthRepository.signUp(
    signUpWithEmailParams: params,
  );

  return result;
});

// 유저 차단
final blockUserProvider =
    FutureProvider.family.autoDispose<bool, String>((ref, userUid) async {
  final result = await AuthRepository.blockUser(
    blockUserUid: userUid,
  );

  return result;
});
