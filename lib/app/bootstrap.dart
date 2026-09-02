import 'package:ddai_community/core/constants/supabase_env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 앱 실행 전에 반드시 완료해야 하는 초기화 작업.
///
/// `main()` 에서 `runApp()` 보다 먼저 호출된다.
class Bootstrap {
  static Future<void> run() async {
    // env file load
    await dotenv.load(
      fileName: '.env',
    );

    // supabase 초기화. 이후 앱 전역에서 `Supabase.instance.client` 로 접근한다.
    // 저장된 세션 복원까지 마친 뒤 반환되므로 `await` 를 생략하면 안 된다.
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }
}
