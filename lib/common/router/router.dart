import 'package:ddai_community/board/view/board_create_screen.dart';
import 'package:ddai_community/board/view/board_detail_screen.dart';
import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/common/view/license_screen.dart';
import 'package:ddai_community/common/view/splash_screen.dart';
import 'package:ddai_community/user/view/login_screen.dart';
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
  ),
  GoRoute(
    path: '/',
    name: HomeTab.routeName,
    builder: (_, __) => const HomeTab(),
    routes: [
      GoRoute(
        path: 'board_detail/:rid',
        name: BoardDetailScreen.routeName,
        builder: (_, state) => BoardDetailScreen(
          id: state.pathParameters['rid']!,
        ),
      ),
      GoRoute(
        path: 'board_create',
        name: BoardCreateScreen.routeName,
        builder: (_, __) => const BoardCreateScreen(),
      ),
      GoRoute(
        path: 'license',
        name: LicenseScreen.routeName,
        builder: (_, __) => const LicenseScreen(),
      ),
    ],
  ),
];
