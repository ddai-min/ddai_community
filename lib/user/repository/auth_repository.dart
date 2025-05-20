import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/main.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final userRef =
          firestore.collection('user').doc(userCredential.user!.uid);

      Map<String, dynamic> userData = UserModel(
        id: userCredential.user!.uid,
        userName: userName,
        isAnonymous: false,
        email: email,
      ).toJson();

      await userRef.set(userData);

      return AuthResult(
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (error) {
      logger.e(error);

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
