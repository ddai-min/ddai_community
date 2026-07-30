import 'package:ddai_community/user/model/auth_parameter.dart';
import 'package:ddai_community/user/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// 이메일 회원가입. 결과로 [AuthResult] 를 반환한다.
@riverpod
Future<AuthResult> signUpWithEmail(Ref ref, SignUpWithEmailParams params) =>
    AuthRepository.signUp(signUpWithEmailParams: params);

/// 유저 차단. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> blockUser(Ref ref, String userUid) =>
    AuthRepository.blockUser(blockUserUid: userUid);
