import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/core/converters/timestamp_converter.dart';
import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

/// 신고 내역 모델. Firestore `report` 컬렉션 문서에 대응한다.
///
/// 신고자(reporter)·피신고자(reported) 정보와 사유, 대상 콘텐츠 id 를 담는다.
@JsonSerializable()
class ReportModel implements ModelWithId {
  @override
  final String id;
  final String reporterUserName;
  final String reporterUserUid;
  final String reportedUserName;
  final String reportedUserUid;
  final String reportReason;

  /// 신고 대상 콘텐츠 id. (예: 게시글 id)
  final String reportContentId;
  @TimestampConverter()
  final DateTime date;

  ReportModel({
    required this.id,
    required this.reporterUserName,
    required this.reporterUserUid,
    required this.reportedUserName,
    required this.reportedUserUid,
    required this.reportReason,
    required this.reportContentId,
    required this.date,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);
}
