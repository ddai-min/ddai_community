import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/component/default_elevated_button.dart';
import 'package:ddai_community/common/component/default_loading_overlay.dart';
import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/common/util/reg_utils.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/auth_provider.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:ddai_community/user/repository/auth_repository.dart';
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

  final formKey = GlobalKey<FormState>();

  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController passwordVerifyTextController = TextEditingController();
  TextEditingController nicknameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    passwordTextController.addListener(_passwordTextControllerListener);
    passwordVerifyTextController.addListener(_passwordTextControllerListener);
  }

  @override
  void dispose() {
    passwordTextController.removeListener(_passwordTextControllerListener);
    passwordVerifyTextController
        .removeListener(_passwordTextControllerListener);

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
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _GuideText(),
                const SizedBox(height: 20),
                _Input(
                  text: '이메일',
                  controller: emailTextController,
                  validator: _emailValidator,
                  forceErrorText: emailErrorText,
                ),
                _Input(
                  text: '비밀번호',
                  controller: passwordTextController,
                  validator: _passwordValidator,
                  obscureText: true,
                  forceErrorText: passwordErrorText,
                ),
                _Input(
                  text: '비밀번호 확인',
                  controller: passwordVerifyTextController,
                  validator: _passwordValidator,
                  obscureText: true,
                  forceErrorText: passwordVerifyErrorText,
                ),
                _Input(
                  text: '닉네임',
                  controller: nicknameTextController,
                  validator: _nicknameValidator,
                ),
                _BottomButton(
                  onPressed: _onSignUp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSignUp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (passwordErrorText != null || passwordVerifyErrorText != null) {
      return;
    }

    DefaultLoadingOverlay.showLoading(context);

    final result = await ref.read(
      signUpWithEmailProvider(
        SignUpWithEmailParams(
          email: emailTextController.text,
          password: passwordTextController.text,
          userName: nicknameTextController.text,
        ),
      ).future,
    );

    DefaultLoadingOverlay.hideLoading(context);

    if (!result.isSuccess) {
      if (result.errorCode == FirebaseAuthExceptionCode.emailAlreadyInUse) {
        setState(() {
          emailErrorText = '이미 사용 중인 이메일입니다.';
        });
      } else if (result.errorCode == FirebaseAuthExceptionCode.weakPassword) {
        setState(() {
          passwordErrorText = '비밀번호를 6글자 이상 사용해주세요.';
        });
      }

      return;
    }

    ref.read(userMeProvider.notifier).update(
          (model) => UserModel(
            id: emailTextController.text,
            userName: nicknameTextController.text,
            isAnonymous: false,
            email: emailTextController.text,
          ),
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return DefaultDialog(
          contentText: '성공적으로\n회원가입하였습니다.',
          buttonText: '확인',
          onPressed: () {
            context.goNamed(
              HomeTab.routeName,
            );
          },
        );
      },
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    } else if (!RegUtils.isValidEmail(email: value)) {
      return '올바른 이메일 형식이 아닙니다.';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    return null;
  }

  String? _nicknameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '닉네임을 입력해주세요.';
    } else if (value.length < 2) {
      return '닉네임은 두 글자 이상 입력해주세요.';
    } else if (value.length > 12) {
      return '닉네임은 12글자 이하로 입력해주세요.';
    } else if (!RegUtils.isValidNickname(nickname: value)) {
      return '닉네임은 한글, 영어, 숫자만 가능합니다.';
    }

    return null;
  }

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
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final String? forceErrorText;

  const _Input({
    required this.text,
    required this.controller,
    this.validator,
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
          validator: validator,
          obscureText: obscureText,
          forceErrorText: forceErrorText,
          maxLength: 50,
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
