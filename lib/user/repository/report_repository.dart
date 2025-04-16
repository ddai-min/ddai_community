import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/main.dart';
import 'package:ddai_community/user/model/report_model.dart';

class ReportRepository {
  static Future<bool> report({
    required String reporterUserName,
    required String reporterUserUid,
    required String reportedUserName,
    required String reportedUserUid,
    required String reportReason,
    required String reportContentId,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final reportRef = firestore.collection('report').doc();

      Map<String, dynamic> reportData = ReportModel(
        id: reportRef.id,
        reporterUserName: reporterUserName,
        reporterUserUid: reporterUserUid,
        reportedUserName: reportedUserName,
        reportedUserUid: reportedUserUid,
        reportReason: reportReason,
        reportContentId: reportContentId,
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
