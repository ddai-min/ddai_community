import 'package:supabase_flutter/supabase_flutter.dart';

/// 앱 전역 Supabase 클라이언트 단축 접근자.
///
/// 모든 repository 가 이 getter 로 Firestore 의 `FirebaseFirestore.instance` 자리를 대신한다.
/// `Bootstrap.run()` 의 `Supabase.initialize` 가 끝난 뒤에만 유효하므로,
/// 최상위 `final` 로 캐싱하지 말고 필요할 때마다 호출한다.
SupabaseClient get supabase => Supabase.instance.client;
