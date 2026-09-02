import 'package:ddai_community/app/app.dart';
import 'package:ddai_community/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 네이티브 스플래시를 그대로 붙잡아 둔다. 강제 업데이트 확인과 초기 라우팅이 끝난 뒤
  // SplashScreen 이 remove() 를 호출한다. 그동안 Flutter 가 그리는 화면은 가려진다.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // .env 로드 및 Supabase 초기화.
  await Bootstrap.run();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
