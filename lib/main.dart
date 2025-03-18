import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/router/router.dart';
import 'package:ddai_community/common/util/data_utils.dart';
import 'package:ddai_community/firebase_options.dart';
import 'package:ddai_community/user/model/user_model.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Logger logger = Logger();

FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // env file load
  await dotenv.load(
    fileName: '.env',
  );

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
                ),
              );
        } else {
          ref.read(userMeProvider.notifier).update(
                (userModel) => UserModel(
                  id: user.email!,
                  userName: user.displayName ?? user.email!,
                  email: user.email,
                  imageUrl: user.photoURL,
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
