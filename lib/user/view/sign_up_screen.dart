import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/main.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static get routeName => 'sign_up';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '회원가입',
      child: Column(
        children: [
          Text('data'),
          Text('data'),
        ],
      ),
    );
  }

  Future<bool> _signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      ref.read(userMeProvider.notifier).update(
            (user) => UserModel(
              id: userCredential.user!.uid,
              userName: userCredential.user!.displayName!,
            ),
          );

      return true;
    } catch (e) {
      logger.e(e);

      return false;
    }
  }
}
