import 'package:flutter_dotenv/flutter_dotenv.dart';

/// `.env` 에서 로드하는 Supabase 접속 정보.
///
/// 최상위 `final` 이라 첫 접근 시점에 평가된다. 즉 **`dotenv.load()` 이후에만**
/// 읽어야 하며, 키가 없으면 `!` 에서 곧바로 크래시한다. (`Bootstrap.run()` 참고)
///
/// publishable 키(`sb_publishable_...`)는 RLS 로 보호되는 공개 키이므로 앱에 넣어도 된다.
/// 반면 secret 키(`sb_secret_...`)는 RLS 를 우회하므로 **앱·`.env`·저장소 어디에도 두지 않는다.**
/// 서버 권한이 필요한 작업(계정 삭제 등)은 Edge Function 런타임에서만 처리한다.
final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
final String supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY']!;
