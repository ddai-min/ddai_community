import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/component/default_text_button.dart';
import 'package:ddai_community/common/view/license_screen.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:ddai_community/user/view/login_screen.dart';
import 'package:ddai_community/user/view/profile_edit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            title: '프로필 수정',
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
          const Expanded(
            child: SizedBox(),
          ),
          _LogoutButton(
            onPressed: () {
              _logout(
                context: context,
              );
            },
          ),
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
    await FirebaseAuth.instance.signOut();

    context.goNamed(
      LoginScreen.routeName,
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
