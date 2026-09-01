import 'package:ddai_community/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 앱 실행 전에 반드시 완료해야 하는 초기화 작업.
///
/// `main()` 에서 `runApp()` 보다 먼저 호출된다.
class Bootstrap {
  static Future<void> run() async {
    // env file load
    await dotenv.load(
      fileName: '.env',
    );

    // firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
