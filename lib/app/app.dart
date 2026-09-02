import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/router/router.dart';
import 'package:ddai_community/core/theme/app_theme.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/auth/data/auth_repository.dart';
import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 앱 루트 위젯.
///
/// Supabase 인증 상태를 전역 유저 상태([userMeProvider])에 동기화하고,
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

    // Supabase 인증 상태 변화를 구독해 전역 유저 상태(userMeProvider)를 동기화한다.
    // 앱 시작 시 저장된 세션 복원(initialSession), 로그인/로그아웃뿐 아니라
    // 프로필 수정(userUpdated) 때도 이벤트가 오므로 표시 이름이 자동으로 따라온다.
    supabase.auth.onAuthStateChange.listen((AuthState authState) {
      final user = authState.session?.user;

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
        // 익명/이메일 분기는 repository 가 담당한다. (표시 이름 규칙을 한곳에 둔다)
        ref
            .read(userMeProvider.notifier)
            .update((userModel) => AuthRepository.userModelFrom(user));
      }

      logger.d('${authState.event} / ${user?.id}');
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
