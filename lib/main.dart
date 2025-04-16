import 'package:ddai_community/bootstrap.dart';
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

Logger logger = Logger();

final String firebaseWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY']!;
final String firebaseAndroidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY']!;
final String firebaseIosApiKey = dotenv.env['FIREBASE_IOS_API_KEY']!;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

    // firebase 로그인 listen
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        ref.read(userMeProvider.notifier).update(
              (userModel) => UserModel(
                id: '',
                userName: '',
                isAnonymous: false,
              ),
            );
      } else {
        if (user.isAnonymous) {
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
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
