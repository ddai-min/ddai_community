import 'package:ddai_community/common/view/home_tab.dart';
import 'package:ddai_community/common/view/splash_screen.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> routes = [
  GoRoute(
    path: '/splash',
    name: SplashScreen.routeName,
    builder: (_, __) => const SplashScreen(),
  ),
  GoRoute(
    path: '/',
    name: HomeTab.routeName,
    builder: (_, __) => const HomeTab(),
  ),
];
