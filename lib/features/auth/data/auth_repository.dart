import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/auth/domain/auth_parameter.dart';
import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 앱에서 개별적으로 처리하는 [FirebaseAuthException] 코드 모음.
///
/// 문자열 [code] 는 Firebase 가 던지는 실제 예외 코드와 매칭되며,
/// 그 외의 예외는 모두 [unknownError] 로 취급한다.
enum FirebaseAuthExceptionCode {
  emailAlreadyInUse('email-already-in-use'),
  weakPassword('weak-password'),
  invalidCredential('invalid-credential'),
  noUser('no-user'),
  tooManyRequests('too-many-requests'),
  unknownError('unknown-error');

  final String code;

  const FirebaseAuthExceptionCode(
    this.code,
  );
}

/// 인증 연산 결과.
///
/// 성공 시 [user] 가, 실패 시 [errorCode] 가 채워진다.
class AuthResult {
  final User? user;
  final FirebaseAuthExceptionCode? errorCode;

  AuthResult({
    this.user,
    this.errorCode,
  });

  /// 인증 성공 여부. ([user] 존재 여부로 판단)
  bool get isSuccess => user != null;
}

/// Firebase 인증 및 계정 관련 연산.
class AuthRepository {
  /// 이메일/비밀번호로 회원가입하고 `user` 컬렉션에 프로필 문서를 생성한다.
  ///
  /// 표시 이름(displayName)도 함께 설정한다. 실패 시 [AuthResult.errorCode] 로
  /// 원인(이메일 중복·약한 비밀번호·요청 과다 등)을 전달한다.
  static Future<AuthResult> signUp({
    required SignUpWithEmailParams signUpWithEmailParams,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: signUpWithEmailParams.email,
        password: signUpWithEmailParams.password,
      );

      await userCredential.user!
          .updateDisplayName(signUpWithEmailParams.userName);

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final userRef =
          firestore.collection('user').doc(userCredential.user!.uid);

      Map<String, dynamic> userData = UserModel(
        id: userCredential.user!.uid,
        userName: signUpWithEmailParams.userName,
        isAnonymous: false,
        email: signUpWithEmailParams.email,
      ).toJson();

      await userRef.set(userData);

      return AuthResult(
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (error) {
      logger.e(error);

      // 사용자에게 다르게 안내해야 하는 코드만 개별 매핑하고, 나머지는 unknownError 로 처리한다.
      if (error.code == FirebaseAuthExceptionCode.tooManyRequests.code) {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.tooManyRequests,
        );
      } else if (error.code ==
          FirebaseAuthExceptionCode.emailAlreadyInUse.code) {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.emailAlreadyInUse,
        );
      } else if (error.code == FirebaseAuthExceptionCode.weakPassword.code) {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.weakPassword,
        );
      }

      return AuthResult(
        errorCode: FirebaseAuthExceptionCode.unknownError,
      );
    } catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: FirebaseAuthExceptionCode.unknownError,
      );
    }
  }

  /// 이메일/비밀번호로 로그인한다.
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResult(
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: FirebaseAuthExceptionCode.unknownError,
      );
    } catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: FirebaseAuthExceptionCode.unknownError,
      );
    }
  }

  /// 익명으로 로그인한다. (회원가입 없이 둘러보기)
  static Future<AuthResult> loginAnonymous() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();

      return AuthResult(
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (error) {
      logger.e(error);

      if (error.code == FirebaseAuthExceptionCode.tooManyRequests.code) {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.tooManyRequests,
        );
      } else {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.unknownError,
        );
      }
    } catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: FirebaseAuthExceptionCode.unknownError,
      );
    }
  }

  /// 현재 계정을 삭제한다.
  ///
  /// 민감한 작업이므로 이메일/비밀번호로 재인증(reauthenticate)한 뒤
  /// Auth 계정과 `user` 프로필 문서를 함께 삭제한다.
  /// 비밀번호가 틀리면 [FirebaseAuthExceptionCode.invalidCredential] 을 반환한다.
  static Future<AuthResult> deleteUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.noUser,
        );
      }

      await user.reauthenticateWithCredential(credential);

      await user.delete();

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final userRef = firestore.collection('user').doc(user.uid);

      await userRef.delete();

      return AuthResult(
        user: user,
      );
    } on FirebaseAuthException catch (error) {
      logger.e(error);

      if (error.code == FirebaseAuthExceptionCode.invalidCredential.code) {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.invalidCredential,
        );
      } else {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.unknownError,
        );
      }
    } catch (error) {
      logger.e(error);

      return AuthResult(
        errorCode: FirebaseAuthExceptionCode.unknownError,
      );
    }
  }

  /// 특정 유저를 차단한다. (`user/{myUid}/blockUser` 에 기록)
  ///
  /// 차단된 유저의 글은 이후 목록 조회에서 제외된다.
  /// ([PaginationRepository.fetchData] 의 whereNotIn 필터 참고)
  static Future<bool> blockUser({
    required String blockUserUid,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return false;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore
          .collection('user')
          .doc(user.uid)
          .collection('blockUser')
          .doc(blockUserUid)
          .set({
        'blockUserUid': blockUserUid,
      });

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }
}
