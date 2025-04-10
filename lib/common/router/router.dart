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

List<GoRoute> routes = [
  GoRoute(
    path: '/splash',
    name: SplashScreen.routeName,
    builder: (_, __) => const SplashScreen(),
  ),
  GoRoute(
    path: '/login',
    name: LoginScreen.routeName,
    builder: (_, __) => const LoginScreen(),
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
        builder: (_, __) => const SignUpScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/',
    name: HomeTab.routeName,
    builder: (_, __) => const HomeTab(),
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
        builder: (_, __) => const BoardCreateScreen(),
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
        builder: (_, __) => const LicenseScreen(),
      ),
    ],
  ),
];
