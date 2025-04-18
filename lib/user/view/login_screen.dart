import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_loading_overlay.dart';
import 'package:ddai_community/common/component/default_text_button.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/user/component/login_text_field.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:ddai_community/user/repository/auth_repository.dart';
import 'package:ddai_community/user/view/eula_screen.dart';
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
  void dispose() {
    super.dispose();

    idTextController.dispose();
    passwordTextController.dispose();
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
            const SizedBox(height: 15),
            if (isLoginError) const _ErrorText(),
            const SizedBox(height: 15),
            _Inputs(
              idTextController: idTextController,
              passwordTextController: passwordTextController,
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
    DefaultLoadingOverlay.showLoading(context);

    final result = await AuthRepository.login(
      email: idTextController.text,
      password: passwordTextController.text,
    );

    DefaultLoadingOverlay.hideLoading(context);

    if (result.isSuccess) {
      setState(() {
        isLoginError = false;
      });

      ref.read(userMeProvider.notifier).update(
            (model) => UserModel(
              id: result.user!.uid,
              userName: result.user!.displayName ?? result.user!.email!,
              isAnonymous: false,
              email: result.user!.email,
            ),
          );

      context.goNamed(
        HomeTab.routeName,
      );
    } else {
      setState(() {
        isLoginError = true;
      });
    }
  }

  void _onSignUp() {
    context.goNamed(
      EulaScreen.routeName,
      queryParameters: {
        'isAnonymous': 'false',
      },
    );
  }

  void _onAnonymous() {
    context.goNamed(
      EulaScreen.routeName,
      queryParameters: {
        'isAnonymous': 'true',
      },
    );
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

  const _Inputs({
    required this.idTextController,
    required this.passwordTextController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginTextField(
          controller: idTextController,
          hintText: '아이디',
        ),
        LoginTextField(
          controller: passwordTextController,
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
