import 'package:ddai_community/app/app.dart';
import 'package:ddai_community/app/app_update.dart';
import 'package:ddai_community/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 네이티브 스플래시를 붙잡아 둔다. 아래 준비가 끝나고 첫 화면이 그려진 뒤
  // App 이 remove() 를 호출한다. 그동안 사용자는 네이티브 스플래시만 본다.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // .env 로드 및 Supabase 초기화. (저장된 세션 복원까지 마친다)
  await Bootstrap.run();

  // 강제 업데이트 확인. UI 가 없는 순수 로직이라 runApp 이전에 끝낼 수 있고,
  // 덕분에 첫 화면을 곧바로 목적지로 띄울 수 있다. (스플래시 화면이 필요 없다)
  final updateStatus = await AppUpdate.check();

  runApp(
    ProviderScope(
      child: App(
        updateStatus: updateStatus,
      ),
    ),
  );
}
