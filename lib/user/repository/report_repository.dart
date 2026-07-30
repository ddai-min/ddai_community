import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/main.dart';
import 'package:ddai_community/user/model/report_model.dart';
import 'package:ddai_community/user/model/report_parameter.dart';

/// 신고(`report` 컬렉션) 관련 Firestore 연산.
class ReportRepository {
  /// 신고 내역을 저장한다. 성공 여부를 bool 로 반환한다.
  static Future<bool> report({
    required ReportParams reportParams,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final reportRef = firestore.collection('report').doc();

      Map<String, dynamic> reportData = ReportModel(
        id: reportRef.id,
        reporterUserName: reportParams.reporterUserName,
        reporterUserUid: reportParams.reporterUserUid,
        reportedUserName: reportParams.reportedUserName,
        reportedUserUid: reportParams.reportedUserUid,
        reportReason: reportParams.reportReason,
        reportContentId: reportParams.reportContentId,
        date: DateTime.now(),
      ).toJson();

      await reportRef.set(reportData);

      return true;
    } catch (error) {
      logger.e(error);

      return false;
    }
  }
}
