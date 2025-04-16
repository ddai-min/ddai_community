import 'dart:io';

import 'package:ddai_community/common/component/default_dialog.dart';
import 'package:ddai_community/common/const/colors.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:ddai_community/user/view/login_screen.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 1),
      () {
        _pushMain();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultLayout(
      backgroundColor: primaryColor,
      child: Center(
        child: Text(
          'DDAI\nCommunity',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _pushMain() async {
    await _checkUpdate();

    context.goNamed(
      ref.read(userMeProvider).id == ''
          ? LoginScreen.routeName
          : HomeTab.routeName,
    );
  }

  Future<void> _checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.fetchAndActivate().then((value) async {
      final currentVersionName = packageInfo.version;
      final latestVersionName = remoteConfig.getString('version_name');

      final currentVersionNameList = currentVersionName
          .split('.')
          .map(
            (e) => int.parse(e),
          )
          .toList();
      final latestVersionNameList = latestVersionName
          .split('.')
          .map(
            (e) => int.parse(e),
          )
          .toList();

      if (currentVersionNameList[0] < latestVersionNameList[0] ||
          currentVersionNameList[1] < latestVersionNameList[1]) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return DefaultDialog(
              contentText: '최신 버전으로 업데이트 해주세요.\n\n업데이트 후 이용 가능합니다.',
              buttonText: '확인',
              onPressed: () {
                exit(0);
              },
            );
          },
        );
      }
    }).catchError((error) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return DefaultDialog(
            contentText: '업데이트를 확인할 수 없습니다.\n\n앱을 종료합니다.',
            buttonText: '확인',
            onPressed: () {
              exit(0);
            },
          );
        },
      );
    });
  }
}
