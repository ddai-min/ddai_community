import 'package:ddai_community/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum FirebaseAuthExceptionCode {
  emailAlreadyInUse,
  weakPassword,
  invalidCredential,
  noUser,
  unknownError,
}

class AuthResult {
  final User? user;
  final FirebaseAuthExceptionCode? errorCode;

  AuthResult({
    this.user,
    this.errorCode,
  });

  bool get isSuccess => user != null;
}

class AuthRepository {
  static Future<AuthResult> signUp({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(userName);

      return AuthResult(
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (error) {
      logger.e(error);

      if (error.code == 'email-already-in-use') {
        return AuthResult(
          errorCode: FirebaseAuthExceptionCode.emailAlreadyInUse,
        );
      } else if (error.code == 'weak-password') {
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

      return AuthResult(
        user: user,
      );
    } on FirebaseAuthException catch (error) {
      logger.e(error);

      if (error.code == 'invalid-credential') {
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
}
