import 'package:ddai_community/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  static Future<User?> signUp({
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

      return userCredential.user;
    } catch (e) {
      logger.e(e);

      return null;
    }
  }
}
