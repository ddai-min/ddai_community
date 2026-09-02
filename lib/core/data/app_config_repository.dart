import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/utils/logger.dart';

/// 앱 전역 설정(`app_config` 테이블) 조회.
///
/// Firebase Remote Config 를 대체한다. **로그인 전에** 읽으므로
/// RLS 정책이 `anon` 롤에도 열려 있어야 한다. (`app_config_select`)
class AppConfigRepository {
  /// 강제 업데이트 비교에 쓰는 최신 버전 문자열(`x.y.z`).
  ///
  /// 조회에 실패하면 null 을 반환한다. 호출부는 이를 "업데이트 확인 불가"로 보고
  /// 앱을 막아야 한다. ([AppUpdate.check] 참고)
  static Future<String?> getVersionName() async {
    try {
      final row = await supabase
          .from('app_config')
          .select('value')
          .eq('key', 'version_name')
          .single();

      return row['value'] as String;
    } catch (error) {
      logger.e(error);

      return null;
    }
  }
}
