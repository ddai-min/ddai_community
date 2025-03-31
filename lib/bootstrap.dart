import 'package:ddai_community/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
