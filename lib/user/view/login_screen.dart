import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_loading_overlay.dart';
import 'package:ddai_community/common/component/default_text_button.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
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
  late TextEditingController idTextController;
  late TextEditingController passwordTextController;

  @override
  void initState() {
    super.initState();

    idTextController = TextEditingController();
    passwordTextController = TextEditingController();
  }

  @override
  void dispose() {
    idTextController.dispose();
    passwordTextController.dispose();

    super.dispose();
  }

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
            const SizedBox(height: 30),
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

  void _onLogin() {
    // context.goNamed(
    //   HomeTab.routeName,
    // );
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
              userName: '익명${userCredential.user!.uid.substring(0, 6)}',
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
