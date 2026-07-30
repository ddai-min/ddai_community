import 'package:ddai_community/bootstrap.dart';
import 'package:ddai_community/common/const/colors.dart';
import 'package:ddai_community/common/router/router.dart';
import 'package:ddai_community/common/util/data_utils.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 전역에서 사용하는 공용 로거.
Logger logger = Logger();

// .env 에서 로드하는 플랫폼별 Firebase API 키.
final String firebaseWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY']!;
final String firebaseAndroidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY']!;
final String firebaseIosApiKey = dotenv.env['FIREBASE_IOS_API_KEY']!;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 로드 및 Firebase 초기화.
  await Bootstrap.run();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

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
      theme: ThemeData(
        fontFamily: 'NotoSans',
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Colors.grey,
          selectionHandleColor: primaryColor,
        ),
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
