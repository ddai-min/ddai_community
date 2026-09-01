import 'package:ddai_community/core/router/router.dart';
import 'package:ddai_community/core/theme/app_theme.dart';
import 'package:ddai_community/core/utils/data_utils.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 앱 루트 위젯.
///
/// Firebase 인증 상태를 전역 유저 상태([userMeProvider])에 동기화하고,
/// 라우터([routes])와 테마([AppTheme])를 주입한 `MaterialApp.router` 를 구성한다.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();

    // Firebase 인증 상태 변화를 구독해 전역 유저 상태(userMeProvider)를 동기화한다.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // 로그아웃(비로그인) 상태: 빈 유저로 초기화한다.
        ref.read(userMeProvider.notifier).update(
              (userModel) => UserModel(
                id: '',
                userName: '',
                isAnonymous: false,
              ),
            );
      } else {
        if (user.isAnonymous) {
          // 익명 로그인: uid 기반의 익명 표시 이름을 부여한다.
          ref.read(userMeProvider.notifier).update(
                (userModel) => UserModel(
                  id: user.uid,
                  userName: DataUtils.setAnonymousName(
                    uid: user.uid,
                  ),
                  isAnonymous: true,
                ),
              );
        } else {
          // 이메일 로그인: displayName(없으면 email)을 표시 이름으로 사용한다.
          ref.read(userMeProvider.notifier).update(
                (userModel) => UserModel(
                  id: user.uid,
                  userName: user.displayName ?? user.email!,
                  isAnonymous: false,
                  email: user.email,
                ),
              );
        }
      }

      logger.d(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: routes,
      initialLocation: '/splash',
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
