import 'package:ddai_community/common/component/default_avatar.dart';
import 'package:ddai_community/common/view/license_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Profile(
            userName: 'UserName',
            image: null,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _License(
            onTap: () => _pushLicenseScreen(context),
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
