import 'dart:io';

import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/features/auth/presentation/screens/login_screen.dart';
import 'package:ddai_community/features/home/presentation/screens/home_tab.dart';
import 'package:ddai_community/features/splash/data/app_config_repository.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 앱 시작 직후의 라우팅 관문.
///
/// **화면 자체는 보이지 않는다.** 스플래시 비주얼은 네이티브(`flutter_native_splash`)가
/// 담당하고, `main()` 이 `preserve()` 로 붙잡아 둔 것을 여기서 `remove()` 한다.
/// 배경색만 네이티브 스플래시와 같게 두어 전환 순간에 색이 튀지 않게 한다.
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
    // 네이티브 스플래시에 가려 보이지 않는다. 색만 맞춰 둔다.
    return const DefaultLayout(
      backgroundColor: primaryColor,
      child: SizedBox.shrink(),
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

    // 목적지 화면이 준비된 뒤에 네이티브 스플래시를 걷는다.
    FlutterNativeSplash.remove();
  }

  /// `app_config.version_name` 과 현재 앱 버전을 비교해 강제 업데이트를 처리한다.
  ///
  /// major 또는 minor 버전이 더 낮으면 업데이트를 안내하고 앱을 종료한다.
  /// (patch 차이는 허용) 조회나 파싱에 실패하면 업데이트 여부를 알 수 없으므로
  /// 마찬가지로 안전하게 앱을 종료한다.
  Future<void> _checkUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final latestVersionName = await AppConfigRepository.getVersionName();

    if (latestVersionName == null) {
      await _showExitDialog('업데이트를 확인할 수 없습니다.\n\n앱을 종료합니다.');

      return;
    }

    // "x.y.z" 문자열을 정수 리스트로 변환해 자리별로 비교한다.
    final List<int> currentVersionNameList;
    final List<int> latestVersionNameList;

    try {
      currentVersionNameList =
          packageInfo.version.split('.').map((e) => int.parse(e)).toList();
      latestVersionNameList =
          latestVersionName.split('.').map((e) => int.parse(e)).toList();
    } catch (error) {
      logger.e(error);

      await _showExitDialog('업데이트를 확인할 수 없습니다.\n\n앱을 종료합니다.');

      return;
    }

    // major 또는 minor 버전이 낮으면 강제 업데이트 대상이다. (patch 차이는 무시)
    if (currentVersionNameList[0] < latestVersionNameList[0] ||
        currentVersionNameList[1] < latestVersionNameList[1]) {
      await _showExitDialog('최신 버전으로 업데이트 해주세요.\n\n업데이트 후 이용 가능합니다.');
    }
  }

  /// 확인을 누르면 앱을 종료하는 안내 다이얼로그. (뒤로 닫을 수 없다)
  ///
  /// 네이티브 스플래시가 덮여 있으면 다이얼로그가 보이지 않으므로 먼저 걷어낸다.
  Future<void> _showExitDialog(String contentText) {
    FlutterNativeSplash.remove();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return DefaultDialog(
          contentText: contentText,
          buttonText: '확인',
          onPressed: () {
            exit(0);
          },
        );
      },
    );
  }
}
