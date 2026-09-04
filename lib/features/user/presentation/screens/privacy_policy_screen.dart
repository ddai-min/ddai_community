import 'package:ddai_community/core/constants/app_links.dart';
import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/utils/link_utils.dart';
import 'package:ddai_community/core/widgets/default_elevated_button.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/default_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 개인정보처리방침 화면.
///
/// 방침 원본은 앱이 아니라 웹([privacyPolicyUrl])에 있다. 그 이유는
/// `core/constants/app_links.dart` 에 적어 두었다.
/// 브라우저로 넘기면 앱을 벗어나므로, 문서만 웹뷰로 앱 안에 띄운다.
///
/// **최상위 라우트다.** 프로필 탭과 EULA 화면(로그인 전) 양쪽에서 열리는데
/// `/` 나 `/login` 아래에 두면 반대쪽에서 갈 수 없다.
/// 그리고 여는 쪽은 `goNamed` 가 아니라 **`pushNamed`** 를 쓴다 —
/// `goNamed` 는 스택을 갈아치워서 AppBar 의 뒤로 가기가 사라진다.
class PrivacyPolicyScreen extends StatefulWidget {
  static String get routeName => 'privacy_policy';

  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  InAppWebViewController? _controller;

  /// 로드가 끝나기 전까지 인디케이터로 빈 웹뷰를 가린다.
  bool _isLoading = true;

  /// 본문 로드 실패 여부.
  ///
  /// 실패해도 웹뷰는 그대로 두고 안내만 그 위에 덮는다.
  /// "다시 시도" 가 [InAppWebViewController.reload] 를 불러야 하는데,
  /// 웹뷰를 걷어내면 컨트롤러도 함께 사라지기 때문이다.
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '개인정보처리방침',
      // 문서 HTML 이 자체 여백을 갖고 있으므로 웹뷰는 화면 끝까지 붙인다.
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(privacyPolicyUrl)),
            initialSettings: InAppWebViewSettings(
              // 정적 문서라 스크립트가 필요 없다. 꺼 두면 바깥 문서를 그대로 띄우는
              // 이 화면의 공격 면이 줄어든다.
              javaScriptEnabled: false,
              // 법적 고지 문서라 확대해서 읽을 수 있어야 한다.
              // Android 는 builtInZoomControls 없이는 핀치 줌이 먹지 않고,
              // displayZoomControls 를 켜면 화면에 +/- 버튼이 떠 버린다.
              supportZoom: true,
              builtInZoomControls: true,
              displayZoomControls: false,
              // false 면 [shouldOverrideUrlLoading] 이 아예 호출되지 않는다.
              useShouldOverrideUrlLoading: true,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (_, _) {
              _setState(isLoading: true, hasError: false);
            },
            onLoadStop: (_, _) {
              _setState(isLoading: false);
            },
            onReceivedError: (_, request, _) {
              // 하위 리소스(이미지 등) 실패로 전체를 오류 처리하지 않는다.
              // 값이 null 인 플랫폼도 있어 `== false` 일 때만 넘긴다.
              if (request.isForMainFrame == false) {
                return;
              }

              _setState(isLoading: false, hasError: true);
            },
            onReceivedHttpError: (_, request, response) {
              if (request.isForMainFrame == false) {
                return;
              }

              // 주소가 바뀌었거나 Pages 배포가 깨지면 404 가 온다.
              // 이때 웹뷰는 성공으로 치고 오류 페이지를 그리므로 여기서 잡아야 한다.
              if ((response.statusCode ?? 0) >= 400) {
                _setState(isLoading: false, hasError: true);
              }
            },
            shouldOverrideUrlLoading: (_, action) async {
              final url = action.request.url.toString();

              // 목차 앵커(#a1)까지 포함해 방침 문서 자신만 웹뷰 안에서 연다.
              if (url.startsWith(privacyPolicyUrl)) {
                return NavigationActionPolicy.ALLOW;
              }

              // 수탁자 방침·분쟁조정위 같은 바깥 링크와 mailto: 는 기본 앱으로 넘긴다.
              // 웹뷰 안에서 허용하면 이용자가 방침 화면인 줄 알고 아무 데나 돌아다니게 되고,
              // 뒤로 갈 방법도 AppBar 뒤로 가기(=화면 종료)뿐이다.
              await LinkUtils.open(url);

              return NavigationActionPolicy.CANCEL;
            },
          ),
          if (_isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
            ),
          if (_hasError)
            Positioned.fill(
              child: _Error(
                onRetry: () {
                  _controller?.reload();
                },
                onOpenBrowser: () {
                  LinkUtils.open(privacyPolicyUrl);
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 웹뷰 콜백은 화면이 사라진 뒤에도 들어올 수 있어 [mounted] 를 먼저 본다.
  void _setState({bool? isLoading, bool? hasError}) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = isLoading ?? _isLoading;
      _hasError = hasError ?? _hasError;
    });
  }
}

/// 로드 실패 안내. 웹뷰 위를 덮으므로 배경이 불투명해야 한다.
class _Error extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onOpenBrowser;

  const _Error({
    required this.onRetry,
    required this.onOpenBrowser,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        // 이 화면의 레이아웃은 여백이 0 이라 안내 문구에는 직접 준다.
        padding: DefaultLayout.contentPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '개인정보처리방침을 불러오지 못했습니다.\n네트워크 상태를 확인한 뒤 다시 시도해주세요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            DefaultElevatedButton(
              onPressed: onRetry,
              text: '다시 시도',
            ),
            DefaultTextButton(
              onPressed: onOpenBrowser,
              text: '브라우저로 열기',
            ),
          ],
        ),
      ),
    );
  }
}
