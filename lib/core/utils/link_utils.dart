import 'package:ddai_community/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

/// 외부 링크 열기 유틸.
class LinkUtils {
  /// [url] 을 기기의 기본 앱(브라우저·메일)으로 연다. 열지 못했으면 `false` 를 반환한다.
  ///
  /// 앱 화면에서 직접 부르는 곳은 없다. 개인정보처리방침 웹뷰가 문서 **안쪽**의
  /// 바깥 링크(수탁자 방침, 분쟁조정위, `mailto:`)를 만났을 때 넘기는 용도다.
  /// 방침 로드가 실패했을 때의 대체 수단이기도 하다.
  ///
  /// repository 와 같은 규칙으로 예외를 삼키고 실패를 `bool` 로만 알린다.
  /// 브라우저나 메일 앱이 없는 기기에서 [launchUrl] 이 던지는 예외로 화면이 죽으면 안 된다.
  ///
  /// Android 11+ 는 `AndroidManifest.xml` 의 `<queries>` 에 선언한 스킴만 열 수 있다.
  /// 새 스킴(`tel:` 등)을 쓰려면 거기에도 추가해야 조용히 실패하지 않는다.
  static Future<bool> open(String url) async {
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      logger.e(e);

      return false;
    }
  }
}
