import 'package:ddai_community/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

/// 외부 링크 열기 유틸.
class LinkUtils {
  /// [url] 을 기기의 기본 브라우저로 연다. 열지 못했으면 `false` 를 반환한다.
  ///
  /// repository 와 같은 규칙으로 예외를 삼키고 실패를 `bool` 로만 알린다.
  /// 브라우저가 없는 기기에서 [launchUrl] 이 던지는 예외로 화면이 죽으면 안 되고,
  /// 안내 문구는 호출부(화면)가 띄우는 편이 자연스럽기 때문이다.
  ///
  /// [LaunchMode.externalApplication] 을 쓴다. 기본값은 플랫폼이 판단해서 iOS 에서는
  /// 앱 안의 웹뷰로 열리는데, 개인정보처리방침처럼 "앱 밖의 공개 문서" 라는 점이
  /// 드러나야 하는 링크는 브라우저로 넘기는 편이 낫다.
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
