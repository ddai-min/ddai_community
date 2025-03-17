import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
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
              _Input(
                text: '이메일',
                controller: emailTextController,
              ),
              _Input(
                text: '비밀번호',
                controller: passwordTextController,
              ),
              _Input(
                text: '비밀번호 확인',
                controller: passwordVerifyTextController,
              ),
              _Input(
                text: '닉네임',
                controller: nicknameTextController,
              ),
              _BottomButton(
                onPressed: () async {
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String text;
  final TextEditingController controller;

  const _Input({
    required this.text,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text),
        DefaultTextField(
          controller: controller,
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
