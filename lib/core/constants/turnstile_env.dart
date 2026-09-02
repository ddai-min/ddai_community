import 'package:flutter_dotenv/flutter_dotenv.dart';

/// `.env` 에서 로드하는 Cloudflare Turnstile(CAPTCHA) 설정.
///
/// sitekey 는 위젯을 식별하는 **공개 값**이라 앱에 들어가도 된다. 토큰을 검증하는
/// secret 은 Supabase 대시보드(Authentication → Attack Protection)에만 두며
/// 앱·`.env`·저장소 어디에도 두지 않는다.
///
/// 다른 env 키와 달리 **없어도 크래시하지 않는다.** 비어 있으면 CAPTCHA 를 쓰지 않는다.
/// Supabase 의 CAPTCHA 스위치는 프로젝트 전역이라 앱 배포 시점과 서버 활성화 시점이
/// 어긋날 수밖에 없는데, 이 분기가 그 간격을 흡수한다.
/// (서버가 꺼져 있으면 토큰을 보내도 무시되고, 켜져 있으면 없을 때만 거절당한다)
final String turnstileSiteKey = dotenv.env['TURNSTILE_SITE_KEY'] ?? '';

/// 토큰 발급용 WebView 가 Turnstile 스크립트를 띄울 때 쓰는 출처.
///
/// 모바일 앱에는 도메인이 없으므로 임의의 값을 쓰되 Cloudflare 대시보드의
/// **Widget Domains 에 등록한 호스트와 같아야 한다.** 다르면 위젯이
/// `110200 Domain not allowed` 로 실패한다.
final String turnstileBaseUrl =
    dotenv.env['TURNSTILE_BASE_URL'] ?? 'http://localhost/';

/// CAPTCHA 사용 여부. sitekey 가 채워져 있으면 켜진 것으로 본다.
bool get isCaptchaEnabled => turnstileSiteKey.isNotEmpty;
