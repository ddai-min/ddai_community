import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

/// 신고 내역 모델. Postgres `report` 테이블의 행에 대응한다.
///
/// 신고자(reporter)·피신고자(reported) 정보와 사유, 대상 콘텐츠 id 를 담는다.
@JsonSerializable(fieldRename: FieldRename.snake)
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

  /// 행 생성 시각. 컬럼명은 `created_at`, 정렬·커서의 기준이다.
  @JsonKey(name: 'created_at')
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
