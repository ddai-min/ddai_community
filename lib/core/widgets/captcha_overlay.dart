import 'dart:async';
import 'dart:convert';

import 'package:ddai_community/core/constants/turnstile_env.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 토큰 발급 제한 시간.
///
/// Turnstile 스크립트를 내려받아 위젯을 그리는 데 기기·회선에 따라 2~3초가 걸린다.
/// 콜백이 끝내 오지 않는 경우(스크립트 차단 등)를 대비한 방어막이라 넉넉하게 잡는다.
/// 이 시간이 없으면 로그인 화면의 로딩 오버레이가 영영 걷히지 않는다.
const Duration _timeout = Duration(seconds: 15);

/// 웹뷰의 JS 가 결과를 돌려보낼 때 쓰는 채널 이름. HTML 안의 호출과 같아야 한다.
const String _channelName = 'TurnstileBridge';

/// Cloudflare Turnstile 토큰을 하나 발급한다. 꺼져 있거나 실패하면 `null`.
///
/// Supabase 의 CAPTCHA 보호가 켜지면 `signUp` · `signInWithPassword` ·
/// `signInAnonymously` 요청에 토큰을 실어야 한다. 세 경로 모두 호출 **직전에** 부른다 —
/// 토큰은 유효기간이 짧고 **1회용**이라, 재사용하면 두 번째 요청이
/// `timeout-or-duplicate` 로 거절되는데 화면에는 "비밀번호가 맞는데 로그인이 안 됨"
/// 으로 보여서 원인을 찾기 어렵다.
///
/// **실패해도 예외를 던지지 않고 `null` 을 반환한다.** 막을지 말지는 서버가 정한다 —
/// 앱이 미리 막으면 서버 설정과 어긋나는 순간(예: 서버는 아직 꺼져 있는데 발급만 실패)
/// 멀쩡한 로그인까지 못 하게 된다. 토큰이 없으면 CAPTCHA 가 켜진 서버만
/// `AuthExceptionCode.captchaFailed` 로 거절한다.
///
/// **웹뷰를 화면에 올려야 동작한다.** Turnstile 은 브라우저 안에서만 돌아가고,
/// 위젯 트리에 붙지 않은 웹뷰는 플랫폼 뷰가 만들어지지 않아 스크립트가 시작되지 않는다.
/// 그래서 눈에 띄지 않는 1×1 [OverlayEntry] 를 잠깐 띄웠다가 걷는다.
/// (호출부가 이미 로딩 오버레이를 띄운 상태라 사용자에게는 로딩만 보인다)
Future<String?> issueCaptchaToken(BuildContext context) async {
  if (!isCaptchaEnabled) {
    return null;
  }

  // 로딩 오버레이(다이얼로그) 위로 올려야 하므로 루트 Overlay 를 쓴다.
  final overlay = Overlay.maybeOf(context, rootOverlay: true);

  if (overlay == null) {
    logger.e('CAPTCHA: Overlay 를 찾지 못했습니다.');

    return null;
  }

  final completer = Completer<String?>();

  final entry = OverlayEntry(
    builder: (_) => Positioned(
      // 크기가 0 이면 플랫폼 뷰가 만들어지지 않아 스크립트가 아예 돌지 않는다.
      // 보이지 않을 만큼만 남기고, 터치는 통과시킨다.
      width: 1,
      height: 1,
      child: IgnorePointer(
        child: _TurnstileView(
          onResult: (token) {
            if (!completer.isCompleted) {
              completer.complete(token);
            }
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);

  try {
    return await completer.future.timeout(_timeout);
  } catch (error) {
    logger.e(error);

    return null;
  } finally {
    // 발급에 실패했더라도 웹뷰는 떠 있으므로 반드시 걷는다.
    entry.remove();
  }
}

/// Turnstile 위젯을 띄우는 웹뷰. 결과가 나오면 [onResult] 로 한 번 알린다.
///
/// 보이지 않는 크기로 올라가므로 화면 구성 요소가 아니다. 이 파일 밖에서 쓰지 않는다.
class _TurnstileView extends StatefulWidget {
  /// 발급 결과. 실패하면 `null` 이 넘어온다.
  final void Function(String? token) onResult;

  const _TurnstileView({
    required this.onResult,
  });

  @override
  State<_TurnstileView> createState() => _TurnstileViewState();
}

class _TurnstileViewState extends State<_TurnstileView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      // Turnstile 은 스크립트로 동작한다. 방침 웹뷰와 달리 반드시 켜야 한다.
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _controller,
    );
  }

  /// 채널을 먼저 등록하고 문서를 띄운다.
  ///
  /// 순서를 뒤집으면 안 된다 — 채널은 **다음 로드부터** 붙으므로, 문서를 먼저 띄우면
  /// JS 가 `TurnstileBridge` 를 찾지 못해 결과가 영영 돌아오지 않는다.
  Future<void> _load() async {
    try {
      await _controller.addJavaScriptChannel(
        _channelName,
        onMessageReceived: _onMessage,
      );

      // baseUrl 이 이 문서의 출처가 된다. Cloudflare 대시보드의 Widget Domains 에
      // 등록한 호스트와 같아야 하고, 다르면 `110200 Domain not allowed` 로 실패한다.
      await _controller.loadHtmlString(
        _buildHtml(),
        baseUrl: turnstileBaseUrl,
      );
    } catch (error) {
      logger.e(error);

      widget.onResult(null);
    }
  }

  /// 웹뷰가 보낸 결과를 해석한다. 토큰이 아니면 실패로 친다.
  void _onMessage(JavaScriptMessage message) {
    try {
      final payload = jsonDecode(message.message) as Map<String, dynamic>;
      final token = payload['token'] as String?;

      if (token != null && token.isNotEmpty) {
        widget.onResult(token);

        return;
      }

      logger.e('CAPTCHA 토큰 발급 실패: ${payload['error']}');
    } catch (error) {
      logger.e(error);
    }

    widget.onResult(null);
  }

  /// Turnstile 위젯을 그리는 문서.
  ///
  /// `render=explicit` 로 두고 스크립트가 준비된 뒤(`onload`) 직접 그린다. 자동 렌더는
  /// 우리가 심은 콜백이 붙기 전에 시작될 수 있다.
  /// 사이트키는 위젯을 식별하는 공개 값이라 문서에 들어가도 된다. (검증용 secret 은
  /// Supabase 대시보드에만 있다)
  String _buildHtml() {
    // 따옴표가 섞여도 깨지지 않도록 JS 문자열 리터럴로 만들어 넣는다.
    final sitekey = jsonEncode(turnstileSiteKey);

    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body style="margin:0">
<div id="widget"></div>
<script>
  function send(payload) {
    $_channelName.postMessage(JSON.stringify(payload));
  }

  function onTurnstileLoad() {
    try {
      turnstile.render('#widget', {
        sitekey: $sitekey,
        callback: function (token) { send({ token: token }); },
        'error-callback': function (code) { send({ error: 'error-' + code }); return true; },
        'timeout-callback': function () { send({ error: 'timeout' }); },
        'expired-callback': function () { send({ error: 'expired' }); }
      });
    } catch (error) {
      send({ error: String(error) });
    }
  }

  window.onerror = function (message) { send({ error: String(message) }); };
</script>
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=onTurnstileLoad&render=explicit" async defer></script>
</body>
</html>
''';
  }
}
