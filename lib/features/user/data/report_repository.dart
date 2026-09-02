import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:ddai_community/core/utils/logger.dart';
import 'package:ddai_community/features/user/domain/report_parameter.dart';

/// 신고(`report` 테이블) 관련 Supabase 연산.
///
/// RLS 상 **작성만 가능하고 조회는 불가**하다(`report_insert` 정책만 있다).
/// 운영자는 Supabase 대시보드에서 확인한다. 읽을 일이 없으므로 대응 모델도 두지 않는다.
class ReportRepository {
  /// 신고 내역을 저장한다. 성공 여부를 bool 로 반환한다.
  ///
  /// `id` 와 `created_at` 은 DB 기본값에 맡긴다.
  /// 신고자·피신고자 uid 는 탈퇴 시 `set null` 이라 신고 내역 자체는 남는다.
  static Future<bool> report({
    required ReportParams reportParams,
  }) async {
    try {
      await supabase.from('report').insert({
        'reporter_user_name': reportParams.reporterUserName,
        'reporter_user_uid': reportParams.reporterUserUid,
        'reported_user_name': reportParams.reportedUserName,
        'reported_user_uid': reportParams.reportedUserUid,
        'report_reason': reportParams.reportReason,
        'report_content_id': reportParams.reportContentId,
      });

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }
}
