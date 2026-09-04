import 'package:ddai_community/features/auth/data/auth_repository.dart';
import 'package:ddai_community/features/auth/domain/auth_parameter.dart';
import 'package:ddai_community/features/user/domain/block_user_model.dart';
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

/// 차단 해제. 결과로 성공 여부(bool)를 반환한다.
@riverpod
Future<bool> unblockUser(Ref ref, String userUid) =>
    AuthRepository.unblockUser(blockUserUid: userUid);

/// 차단한 유저 목록. 차단/해제 후에는 `ref.invalidate` 로 다시 읽는다.
@riverpod
Future<List<BlockUserModel>> blockUserList(Ref ref) =>
    AuthRepository.getBlockUserList();
