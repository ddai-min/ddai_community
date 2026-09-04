/// 앱이 외부 브라우저로 여는 공개 문서 링크.
///
/// 개인정보처리방침은 **앱 화면이 아니라 웹에 둔다.** 처리 항목·수탁자가 바뀔 때마다
/// 고쳐야 하는 문서인데, 본문을 앱에 박아 넣으면 문구 한 줄을 고치는 데도
/// 스토어 심사와 `app_config` 강제 업데이트를 거쳐야 한다.
/// (이용 약관이 `eula_screen.dart` 에 하드코딩된 것은 로그인 전 동의 화면이라
/// 네트워크 없이도 보여야 하기 때문이며, 거의 바뀌지 않는다는 전제가 붙어 있다)
///
/// 문서 원본은 저장소의 `docs/privacy-policy.html` 이고 GitHub Pages 가 이 주소로 서빙한다.
///
/// **주소를 바꾸면 App Store Connect 와 Play Console 의 개인정보처리방침 URL 도
/// 같이 바꿔야 한다.** 두 스토어 모두 필수 입력값이라 링크가 깨지면 심사에서 반려된다.
const privacyPolicyUrl =
    'https://ddai-min.github.io/ddai_community/privacy-policy.html';
