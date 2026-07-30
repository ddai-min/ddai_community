import 'package:ddai_community/board/view/board_create_screen.dart';
import 'package:ddai_community/board/view/board_detail_screen.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/common/view/license_screen.dart';
import 'package:ddai_community/common/view/splash_screen.dart';
import 'package:ddai_community/user/view/eula_screen.dart';
import 'package:ddai_community/user/view/login_screen.dart';
import 'package:ddai_community/user/view/profile_edit_screen.dart';
import 'package:ddai_community/user/view/sign_up_screen.dart';
import 'package:go_router/go_router.dart';

/// go_router 라우트 정의.
///
/// 로그인 플로우(`/login` 하위의 `/eula`·`/sign_up`)와 메인 플로우
/// (`/` 하위의 게시글 상세/작성, 프로필 수정, 라이선스)로 구성된다.
/// 화면 간 값 전달은 path parameter(`:id`)와 query parameter(`isAnonymous` 등)를 사용한다.
List<GoRoute> routes = [
  GoRoute(
    path: '/splash',
    name: SplashScreen.routeName,
    builder: (_, _) => const SplashScreen(),
  ),
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
];
