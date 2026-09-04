import 'package:ddai_community/features/auth/presentation/screens/eula_screen.dart';
import 'package:ddai_community/features/auth/presentation/screens/login_screen.dart';
import 'package:ddai_community/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:ddai_community/features/board/presentation/screens/board_create_screen.dart';
import 'package:ddai_community/features/board/presentation/screens/board_detail_screen.dart';
import 'package:ddai_community/features/home/presentation/screens/home_tab.dart';
import 'package:ddai_community/features/user/presentation/screens/license_screen.dart';
import 'package:ddai_community/features/user/presentation/screens/privacy_policy_screen.dart';
import 'package:ddai_community/features/user/presentation/screens/profile_edit_screen.dart';
import 'package:go_router/go_router.dart';

/// go_router 라우트 정의.
///
/// 로그인 플로우(`/login` 하위의 `/eula`·`/sign_up`)와 메인 플로우
/// (`/` 하위의 게시글 상세/작성, 프로필 수정, 라이선스)로 구성되고,
/// 양쪽에서 모두 열리는 `/privacy_policy` 만 최상위에 둔다.
/// 시작 위치는 세션 유무에 따라 `app/app.dart` 가 정한다. (스플래시 라우트는 없다)
/// 화면 간 값 전달은 path parameter(`:id`)와 query parameter(`isAnonymous` 등)를 사용한다.
List<GoRoute> routes = [
  GoRoute(
    path: '/login',
    name: LoginScreen.routeName,
    builder: (_, _) => const LoginScreen(),
    routes: [
      GoRoute(
        path: '/eula',
        name: EulaScreen.routeName,
        builder: (_, state) => EulaScreen(
          isAnonymous: state.uri.queryParameters['isAnonymous'] == 'true',
        ),
      ),
      GoRoute(
        path: '/sign_up',
        name: SignUpScreen.routeName,
        builder: (_, _) => const SignUpScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/',
    name: HomeTab.routeName,
    builder: (_, _) => const HomeTab(),
    routes: [
      GoRoute(
        path: 'board_detail/:id',
        name: BoardDetailScreen.routeName,
        builder: (_, state) => BoardDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: 'board_create',
        name: BoardCreateScreen.routeName,
        builder: (_, _) => const BoardCreateScreen(),
      ),
      GoRoute(
        path: 'profile_edit',
        name: ProfileEditScreen.routeName,
        builder: (_, state) => ProfileEditScreen(
          userName: state.uri.queryParameters['userName']!,
          email: state.uri.queryParameters['email']!,
        ),
      ),
      GoRoute(
        path: 'license',
        name: LicenseScreen.routeName,
        builder: (_, _) => const LicenseScreen(),
      ),
    ],
  ),
  // 프로필 탭(`/` 하위)과 EULA 화면(`/login` 하위) 양쪽에서 열리므로 어느 한쪽에
  // 넣으면 반대쪽에서 갈 수 없다. 그래서 최상위에 둔다.
  // 여는 쪽은 `goNamed` 가 아니라 `pushNamed` 를 쓴다 — 최상위 라우트로 `go` 하면
  // 스택이 통째로 갈리면서 뒤로 가기가 사라진다.
  GoRoute(
    path: '/privacy_policy',
    name: PrivacyPolicyScreen.routeName,
    builder: (_, _) => const PrivacyPolicyScreen(),
  ),
];
