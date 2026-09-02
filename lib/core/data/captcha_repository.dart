import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:ddai_community/core/constants/turnstile_env.dart';
import 'package:ddai_community/core/utils/logger.dart';

/// Cloudflare Turnstile 토큰 발급.
///
/// Supabase 의 CAPTCHA 보호가 켜지면 `signUp` · `signInWithPassword` ·
/// `signInAnonymously` 요청에 토큰을 실어야 한다. 발급은 headless WebView 안에서
/// 끝나므로 화면도 `BuildContext` 도 필요 없고, 그래서 data 계층에 둔다.
///
/// **실패해도 예외를 던지지 않고 `null` 을 반환한다.** 막을지 말지는 서버가 정한다 —
/// 앱이 미리 막으면 서버 설정과 어긋나는 순간(예: 서버는 아직 꺼져 있는데 발급만 실패)
/// 멀쩡한 로그인까지 못 하게 된다. 토큰이 없으면 CAPTCHA 가 켜진 서버만
/// [AuthExceptionCode.captchaFailed] 로 거절한다.
class CaptchaRepository {
  /// 토큰 발급 제한 시간.
  ///
  /// 패키지의 `getToken()` 은 **스스로 끝나지 않는다.** 스크립트 로드가 8초 안에
  /// 안 되면 `onTimeout` 콜백만 부르고 Future 는 계속 매달려 있어서, 감싸지 않으면
  /// 로딩 오버레이가 영영 걷히지 않는다. 그 8초보다는 넉넉하게 잡는다.
  static const Duration _timeout = Duration(seconds: 15);

  /// CAPTCHA 토큰을 하나 발급한다. 꺼져 있거나 실패하면 `null`.
  ///
  /// Turnstile 토큰은 **1회용**이라 호출할 때마다 인스턴스를 새로 만든다.
  /// 재사용하면 두 번째 요청이 `timeout-or-duplicate` 로 거절되는데, 화면에는
  /// "비밀번호가 맞는데 로그인이 안 됨" 으로 보여서 원인을 찾기 어렵다.
  static Future<String?> issueToken() async {
    if (!isCaptchaEnabled) {
      return null;
    }

    CloudflareTurnstile? turnstile;

    try {
      turnstile = CloudflareTurnstile.invisible(
        siteKey: turnstileSiteKey,
        baseUrl: turnstileBaseUrl,
      );

      return await turnstile.getToken().timeout(_timeout);
    } catch (error) {
      logger.e(error);

      return null;
    } finally {
      // 발급에 실패했더라도 WebView 는 떠 있으므로 반드시 정리한다.
      await turnstile?.dispose();
    }
  }
}
