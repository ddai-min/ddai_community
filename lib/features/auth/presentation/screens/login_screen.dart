import 'package:ddai_community/core/widgets/default_elevated_button.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/default_loading_overlay.dart';
import 'package:ddai_community/core/widgets/default_text_button.dart';
import 'package:ddai_community/features/auth/data/auth_repository.dart';
import 'package:ddai_community/features/auth/presentation/screens/eula_screen.dart';
import 'package:ddai_community/features/auth/presentation/widgets/login_text_field.dart';
import 'package:ddai_community/features/home/presentation/screens/home_tab.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 로그인 화면.
///
/// 이메일/비밀번호 로그인, 익명(둘러보기) 로그인, 회원가입 이동을 제공한다.
/// 익명 로그인과 회원가입은 [EulaScreen] 의 약관 동의를 거친다.
class LoginScreen extends ConsumerStatefulWidget {
  static String get routeName => 'login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  TextEditingController idTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  /// 직전 로그인 실패 사유. `null` 이면 오류 문구를 숨긴다.
  AuthExceptionCode? loginErrorCode;

  @override
  void dispose() {
    super.dispose();

    idTextController.dispose();
    passwordTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar();
    final availableHeight =
        MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top -
        DefaultLayout.contentPadding.vertical;

    return DefaultLayout(
      title: 'DDAI Community',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: availableHeight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Title(),
            const SizedBox(height: 15),
            if (loginErrorCode != null) _ErrorText(errorCode: loginErrorCode!),
            const SizedBox(height: 15),
            Form(
              key: formKey,
              child: _Inputs(
                idTextController: idTextController,
                passwordTextController: passwordTextController,
                idValidator: _idValidator,
                passwordValidator: _passwordValidator,
              ),
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
    if (!formKey.currentState!.validate()) {
      return;
    }

    DefaultLoadingOverlay.showLoading(context);

    final result = await AuthRepository.login(
      email: idTextController.text,
      password: passwordTextController.text,
    );

    DefaultLoadingOverlay.hideLoading(context);

    if (result.isSuccess) {
      setState(() {
        loginErrorCode = null;
      });

      ref.read(userMeProvider.notifier).update((model) => result.user!);

      context.goNamed(
        HomeTab.routeName,
      );
    } else {
      setState(() {
        loginErrorCode = result.errorCode;
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

  String? _idValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    return null;
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
  final AuthExceptionCode errorCode;

  const _ErrorText({
    required this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    // CAPTCHA 실패는 입력이 틀린 게 아니라 재시도로 풀리는 문제다.
    // 자격증명 오류와 같은 문구를 보여주면 유저가 비밀번호를 계속 고치게 된다.
    final message = switch (errorCode) {
      AuthExceptionCode.captchaFailed =>
        '자동 가입 방지 확인에 실패했습니다.\n네트워크 상태를 확인한 뒤 다시 시도해주세요.',
      AuthExceptionCode.tooManyRequests => '요청이 너무 많습니다.\n잠시 후 다시 시도해주세요.',
      _ => '아이디 또는 패스워드가 일치하지 않습니다.',
    };

    return Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _Inputs extends StatelessWidget {
  final TextEditingController idTextController;
  final FormFieldValidator<String>? idValidator;
  final TextEditingController passwordTextController;
  final FormFieldValidator<String>? passwordValidator;

  const _Inputs({
    required this.idTextController,
    required this.passwordTextController,
    this.idValidator,
    this.passwordValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginTextField(
          controller: idTextController,
          validator: idValidator,
          hintText: '아이디',
        ),
        LoginTextField(
          controller: passwordTextController,
          validator: passwordValidator,
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
    return Column(
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
    );
  }
}

TextStyle loginTextStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 32,
);
