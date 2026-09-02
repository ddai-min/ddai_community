import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/default_text_button.dart';
import 'package:ddai_community/features/auth/data/auth_repository.dart';
import 'package:ddai_community/features/auth/presentation/screens/login_screen.dart';
import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:ddai_community/features/user/presentation/screens/license_screen.dart';
import 'package:ddai_community/features/user/presentation/screens/profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 프로필 탭 화면. ([HomeTab] 의 세 번째 탭)
///
/// 닉네임·이메일을 표시하고 프로필 관리, 오픈소스 라이선스, 로그아웃 진입점을 제공한다.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMe = ref.watch(userMeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Profile(
            userName: userMe.userName,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _List(
            title: '프로필 관리',
            onTap: () {
              _pushProfileEditScreen(
                context: context,
                userMe: userMe,
              );
            },
          ),
          _List(
            title: '오픈소스 라이센스',
            onTap: () {
              context.goNamed(
                LicenseScreen.routeName,
              );
            },
          ),
          const SizedBox(height: 50),
          _LogoutButton(
            onPressed: () {
              _logout(
                context: context,
              );
            },
          ),
          const Expanded(
            child: SizedBox(),
          ),
          Text(
            '문의사항은 yoda3714@gmail.com으로\n연락주시기 바랍니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.0,
            ),
          )
        ],
      ),
    );
  }

  void _pushProfileEditScreen({
    required BuildContext context,
    required UserModel userMe,
  }) {
    if (userMe.isAnonymous) {
      showDialog(
        context: context,
        builder: (context) {
          return DefaultDialog(
            contentText: '로그인 후\n프로필을 수정할 수 있습니다.',
            buttonText: '확인',
            onPressed: () {
              context.pop();
            },
          );
        },
      );

      return;
    }

    context.goNamed(
      ProfileEditScreen.routeName,
      queryParameters: {
        'userName': userMe.userName,
        'email': userMe.email!,
      },
    );
  }

  void _logout({
    required BuildContext context,
  }) async {
    showDialog(
      context: context,
      builder: (context) {
        return DefaultDialog(
          contentText: '정말로 로그아웃 하시겠습니까?',
          buttonText: '로그아웃',
          onPressed: () async {
            await AuthRepository.logout();

            context.goNamed(
              LoginScreen.routeName,
            );
          },
        );
      },
    );
  }
}

class _Profile extends StatelessWidget {
  final String userName;

  const _Profile({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      userName,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _List extends StatelessWidget {
  final String title;
  final GestureTapCallback onTap;

  const _List({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: onTap,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextButton(
      onPressed: onPressed,
      text: '로그아웃',
    );
  }
}
