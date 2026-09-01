import 'package:flutter_dotenv/flutter_dotenv.dart';

/// `.env` 에서 로드하는 플랫폼별 Firebase API 키.
///
/// 생성 파일인 `firebase_options.dart` 가 하드코딩 대신 이 값들을 참조한다.
/// (`flutterfire configure` 로 재생성 시 이 참조를 다시 적용해야 한다.)
final String firebaseWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY']!;
final String firebaseAndroidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY']!;
final String firebaseIosApiKey = dotenv.env['FIREBASE_IOS_API_KEY']!;
