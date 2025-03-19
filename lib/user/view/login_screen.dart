import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_loading_overlay.dart';
import 'package:ddai_community/common/component/default_text_button.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/common/util/data_utils.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/main.dart';
import 'package:ddai_community/user/component/login_text_field.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:ddai_community/user/view/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static get routeName => 'login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController idTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  bool isLoginError = false;

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: 'DDAI Community',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Title(),
            const SizedBox(height: 15),
            if (isLoginError) const _ErrorText(),
            const SizedBox(height: 15),
            _Inputs(
              idTextController: idTextController,
              passwordTextController: passwordTextController,
              onIdChanged: (String value) {
                value = idTextController.text;
              },
              onPasswordChanged: (String value) {
                value = passwordTextController.text;
              },
            ),
            _Buttons(
              onLogin: _onLogin,
              onSignUp: _onSignUp,
              onAnonymous: _onAnonymous,
            ),
          ],
        ),
      ),
    );
  }

  void _onLogin() async {
    try {
      DefaultLoadingOverlay.showLoading(context);

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: idTextController.text,
        password: passwordTextController.text,
      );

      if (userCredential.user != null) {
        setState(() {
          isLoginError = false;
        });

        ref.read(userMeProvider.notifier).update(
              (model) => UserModel(
                id: userCredential.user!.email!,
                userName: userCredential.user!.displayName ??
                    userCredential.user!.email!,
                email: userCredential.user!.email,
                imageUrl: userCredential.user!.photoURL,
              ),
            );

        context.goNamed(
          HomeTab.routeName,
        );
      } else {
        throw FirebaseAuthException;
      }

      DefaultLoadingOverlay.hideLoading(context);
    } on FirebaseAuthException {
      DefaultLoadingOverlay.hideLoading(context);

      setState(() {
        isLoginError = true;
      });
    } catch (error) {
      DefaultLoadingOverlay.hideLoading(context);

      logger.e(error);
    }
  }

  void _onSignUp() {
    context.goNamed(
      SignUpScreen.routeName,
    );
  }

  void _onAnonymous() async {
    try {
      DefaultLoadingOverlay.showLoading(context);

      final userCredential = await FirebaseAuth.instance.signInAnonymously();

      ref.read(userMeProvider.notifier).update(
            (user) => UserModel(
              id: userCredential.user!.uid,
              userName: DataUtils.setAnonymousName(
                uid: userCredential.user!.uid,
              ),
            ),
          );

      DefaultLoadingOverlay.hideLoading(context);

      context.goNamed(
        HomeTab.routeName,
      );
    } catch (e) {
      DefaultLoadingOverlay.hideLoading(context);

      logger.e(e);
    }
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '로그인',
          style: loginTextStyle,
        ),
        Text(
          '환영합니다!',
          style: loginTextStyle.copyWith(
            fontSize: 20.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '아이디 또는 패스워드가 일치하지 않습니다.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.red,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _Inputs extends StatelessWidget {
  final TextEditingController idTextController;
  final TextEditingController passwordTextController;
  final ValueChanged<String> onIdChanged;
  final ValueChanged<String> onPasswordChanged;

  const _Inputs({
    required this.idTextController,
    required this.passwordTextController,
    required this.onIdChanged,
    required this.onPasswordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginTextField(
          controller: idTextController,
          onChanged: onIdChanged,
          hintText: '아이디',
        ),
        LoginTextField(
          controller: passwordTextController,
          onChanged: onPasswordChanged,
          hintText: '비밀번호',
          obscureText: true,
        ),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onAnonymous;

  const _Buttons({
    required this.onLogin,
    required this.onSignUp,
    required this.onAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultElevatedButton(
            onPressed: onLogin,
            text: '로그인',
          ),
          DefaultTextButton(
            onPressed: onSignUp,
            text: '회원가입',
          ),
          const Text(
            '또는',
            textAlign: TextAlign.center,
          ),
          DefaultTextButton(
            onPressed: onAnonymous,
            text: '익명으로 시작하기',
          ),
        ],
      ),
    );
  }
}

TextStyle loginTextStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 32,
);
