import 'dart:io';

import 'package:ddai_community/app/app_update.dart';
import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/router/router.dart';
import 'package:ddai_community/core/theme/app_theme.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/features/auth/data/auth_repository.dart';
import 'package:ddai_community/features/user/domain/user_model.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 앱 루트 위젯.
///
/// 시작에 필요한 판단은 모두 `main()` 에서 끝난 뒤 여기로 전달된다.
/// 이 위젯은 그 결과에 따라 **라우터를 띄울지 차단 화면을 띄울지**만 정한다.
/// (별도의 스플래시 화면은 없다 — 비주얼은 네이티브 스플래시가 담당한다)
///
/// 그 밖에 Supabase 인증 상태를 전역 유저 상태([userMeProvider])에 동기화한다.
class App extends ConsumerStatefulWidget {
  /// `main()` 에서 미리 확인한 강제 업데이트 결과.
  final AppUpdateStatus updateStatus;

  const App({
    super.key,
    required this.updateStatus,
  });

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  /// 라우터는 한 번만 만든다. `build()` 마다 새로 만들면 내비게이션 이력이 사라진다.
  late final GoRouter _router;

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
        ref
            .read(userMeProvider.notifier)
            .update(
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

    // `Supabase.initialize` 가 저장된 세션 복원까지 끝낸 뒤이므로 여기서 바로 판정할 수 있다.
    // (userMeProvider 는 위 리스너가 비동기로 채우므로 이 시점에는 아직 비어 있을 수 있다)
    _router = GoRouter(
      routes: routes,
      initialLocation: supabase.auth.currentSession == null ? '/login' : '/',
    );

    // 첫 프레임이 그려진 뒤 네이티브 스플래시를 걷는다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 업데이트가 필요하거나 확인에 실패했으면 라우터를 아예 띄우지 않는다.
    if (widget.updateStatus != AppUpdateStatus.ok) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _UpdateBlocker(status: widget.updateStatus),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}

/// 앱 사용을 막는 안내 화면. 확인을 누르면 앱을 종료한다.
///
/// 라우터 자체를 띄우지 않으므로 다른 화면으로 빠져나갈 수 없다.
class _UpdateBlocker extends StatefulWidget {
  final AppUpdateStatus status;

  const _UpdateBlocker({
    required this.status,
  });

  @override
  State<_UpdateBlocker> createState() => _UpdateBlockerState();
}

class _UpdateBlockerState extends State<_UpdateBlocker> {
  @override
  void initState() {
    super.initState();

    // 다이얼로그는 Navigator 가 준비된 첫 프레임 이후에 띄운다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return DefaultDialog(
            contentText: widget.status == AppUpdateStatus.updateRequired
                ? '최신 버전으로 업데이트 해주세요.\n\n업데이트 후 이용 가능합니다.'
                : '업데이트를 확인할 수 없습니다.\n\n앱을 종료합니다.',
            buttonText: '확인',
            onPressed: () {
              exit(0);
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 다이얼로그 뒤에는 네이티브 스플래시와 같은 색만 깔아 전환 시 색이 튀지 않게 한다.
    return const DefaultLayout(
      backgroundColor: primaryColor,
      child: SizedBox.shrink(),
    );
  }
}
