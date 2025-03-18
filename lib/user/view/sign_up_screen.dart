import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_loading_overlay.dart';
import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/user/provider/auth_provider.dart';
import 'package:ddai_community/user/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static get routeName => 'sign_up';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  String? emailErrorText;
  String? passwordErrorText;
  String? passwordVerifyErrorText;
  String? nicknameErrorText;

  late TextEditingController emailTextController;
  late TextEditingController passwordTextController;
  late TextEditingController passwordVerifyTextController;
  late TextEditingController nicknameTextController;

  @override
  void initState() {
    super.initState();

    emailTextController = TextEditingController();
    passwordTextController = TextEditingController();
    passwordVerifyTextController = TextEditingController();
    nicknameTextController = TextEditingController();

    emailTextController.addListener(_emailTextControllerListener);
    passwordTextController.addListener(_passwordTextControllerListener);
    passwordVerifyTextController.addListener(_passwordTextControllerListener);
    nicknameTextController.addListener(_nicknameTextControllerListener);
  }

  @override
  void dispose() {
    emailTextController.removeListener(_emailTextControllerListener);
    passwordTextController.removeListener(_passwordTextControllerListener);
    passwordVerifyTextController
        .removeListener(_passwordTextControllerListener);
    nicknameTextController.removeListener(_nicknameTextControllerListener);

    emailTextController.dispose();
    passwordTextController.dispose();
    passwordVerifyTextController.dispose();
    nicknameTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '회원가입',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _GuideText(),
              const SizedBox(height: 20),
              _Input(
                text: '이메일',
                controller: emailTextController,
                forceErrorText: emailErrorText,
              ),
              _Input(
                text: '비밀번호',
                controller: passwordTextController,
                obscureText: true,
                forceErrorText: passwordErrorText,
              ),
              _Input(
                text: '비밀번호 확인',
                controller: passwordVerifyTextController,
                obscureText: true,
                forceErrorText: passwordVerifyErrorText,
              ),
              _Input(
                text: '닉네임',
                controller: nicknameTextController,
                forceErrorText: nicknameErrorText,
              ),
              _BottomButton(
                onPressed: _onSignUp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSignUp() {
    final result = ref.read(
      signUpWithEmailProvider(
        SignUpWithEmailParams(
          email: emailTextController.text,
          password: passwordTextController.text,
          userName: nicknameTextController.text,
        ),
      ),
    );

    result.when(
      loading: () => DefaultLoadingOverlay.showLoading(context),
      error: (error, stack) {},
      data: (user) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return DefaultDialog(
              contentText: '성공적으로\n회원가입하였습니다.',
              buttonText: '확인',
              onPressed: () {
                context.goNamed(
                  LoginScreen.routeName,
                );
              },
            );
          },
        );
      },
    );
  }

  void _emailTextControllerListener() {}

  void _passwordTextControllerListener() {
    if (passwordTextController.text.isNotEmpty &&
        passwordVerifyTextController.text.isNotEmpty &&
        passwordTextController.text != passwordVerifyTextController.text) {
      setState(() {
        passwordVerifyErrorText = '비밀번호가 일치하지 않습니다.';
      });
    } else {
      setState(() {
        passwordErrorText = null;
        passwordVerifyErrorText = null;
      });
    }
  }

  void _nicknameTextControllerListener() {
    if (nicknameTextController.text.length < 2) {
      setState(() {
        nicknameErrorText = '닉네임은 두 글자 이상 입력해주세요.';
      });
    }
  }
}

class _GuideText extends StatelessWidget {
  const _GuideText();

  @override
  Widget build(BuildContext context) {
    return Text(
      '모든 사항을 반드시 입력해주세요.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.grey[700],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final bool obscureText;
  final String? forceErrorText;

  const _Input({
    required this.text,
    required this.controller,
    this.obscureText = false,
    this.forceErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text),
        DefaultTextField(
          controller: controller,
          obscureText: obscureText,
          forceErrorText: forceErrorText,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BottomButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultElevatedButton(
            onPressed: onPressed,
            text: '가입하기',
          ),
        ],
      ),
    );
  }
}
