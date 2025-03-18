import 'package:ddai_community/common/component/default_avatar.dart';
import 'package:ddai_community/common/component/default_text_button.dart';
import 'package:ddai_community/common/view/license_screen.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:ddai_community/user/view/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userMe = ref.read(userMeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Profile(
            userName: userMe.userName,
            image: userMe.imageUrl != null
                ? Image.network(userMe.imageUrl!)
                : null,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _License(
            onTap: () => _pushLicenseScreen(context),
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

  void _pushLicenseScreen(BuildContext context) {
    context.goNamed(
      LicenseScreen.routeName,
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
  final Image? image;

  const _Profile({
    required this.userName,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultAvatar(
          image: image,
          width: 80,
          height: 80,
        ),
        const SizedBox(width: 10),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _License extends StatelessWidget {
  final GestureTapCallback onTap;

  const _License({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text(
        '오픈소스 라이센스',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
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
