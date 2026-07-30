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

/// 앱 시작 시 표시되는 스플래시 화면.
///
/// 최소 1초 노출 후 강제 업데이트 여부를 확인하고, 로그인 상태에 따라
/// 홈 또는 로그인 화면으로 이동한다.
class SplashScreen extends ConsumerStatefulWidget {
  static String get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 스플래시를 최소 1초 노출한 뒤 다음 화면으로 이동한다.
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

  /// 업데이트 확인 후 로그인 상태에 따라 홈/로그인 화면으로 분기한다.
  void _pushMain() async {
    await _checkUpdate();

    // userMeProvider 의 id 가 비어 있으면 비로그인 상태로 간주한다.
    context.goNamed(
      ref.read(userMeProvider).id == ''
          ? LoginScreen.routeName
          : HomeTab.routeName,
    );
  }

  /// Remote Config 의 `version_name` 과 현재 앱 버전을 비교해 강제 업데이트를 처리한다.
  ///
  /// major 또는 minor 버전이 더 낮으면 업데이트를 안내하고 앱을 종료한다.
  /// (patch 차이는 허용) 조회 자체가 실패하면 안전하게 앱을 종료한다.
  Future<void> _checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.fetchAndActivate().then((value) async {
      final currentVersionName = packageInfo.version;
      final latestVersionName = remoteConfig.getString('version_name');

      // "x.y.z" 문자열을 정수 리스트로 변환해 자리별로 비교한다.
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

      // major 또는 minor 버전이 낮으면 강제 업데이트 대상이다. (patch 차이는 무시)
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
      // Remote Config 조회 실패 시 업데이트 확인이 불가하므로 앱을 종료한다.
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
