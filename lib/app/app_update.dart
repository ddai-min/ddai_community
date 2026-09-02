import 'package:ddai_community/core/data/app_config_repository.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 강제 업데이트 확인 결과.
enum AppUpdateStatus {
  /// 최신이거나 patch 차이뿐이다. 앱을 그대로 사용한다.
  ok,

  /// major 또는 minor 가 낮다. 업데이트 전에는 사용할 수 없다.
  updateRequired,

  /// `app_config` 조회나 버전 파싱에 실패했다.
  /// 업데이트 여부를 알 수 없는 채로 앱을 열어두지 않기 위해 [updateRequired] 와 같이 막는다.
  checkFailed,
}

/// 앱 시작 시 한 번 수행하는 강제 업데이트 확인.
///
/// UI 를 갖지 않는 순수 로직이라 `runApp()` 이전에 호출할 수 있다.
/// 결과에 따라 앱 루트([App])가 라우터를 띄울지 차단 화면을 띄울지 정한다.
class AppUpdate {
  const AppUpdate._();

  /// `app_config.version_name` 과 현재 앱 버전의 major/minor 를 비교한다.
  /// (patch 차이는 허용)
  static Future<AppUpdateStatus> check() async {
    final latestVersionName = await AppConfigRepository.getVersionName();

    if (latestVersionName == null) {
      return AppUpdateStatus.checkFailed;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();

      // "x.y.z" 문자열을 정수 리스트로 변환해 자리별로 비교한다.
      final currentVersionNameList =
          packageInfo.version.split('.').map((e) => int.parse(e)).toList();
      final latestVersionNameList =
          latestVersionName.split('.').map((e) => int.parse(e)).toList();

      // major 또는 minor 버전이 낮으면 강제 업데이트 대상이다.
      if (currentVersionNameList[0] < latestVersionNameList[0] ||
          currentVersionNameList[1] < latestVersionNameList[1]) {
        return AppUpdateStatus.updateRequired;
      }

      return AppUpdateStatus.ok;
    } catch (error) {
      logger.e(error);

      return AppUpdateStatus.checkFailed;
    }
  }
}
