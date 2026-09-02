// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
  id: json['id'] as String,
  reporterUserName: json['reporter_user_name'] as String,
  reporterUserUid: json['reporter_user_uid'] as String,
  reportedUserName: json['reported_user_name'] as String,
  reportedUserUid: json['reported_user_uid'] as String,
  reportReason: json['report_reason'] as String,
  reportContentId: json['report_content_id'] as String,
  date: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporter_user_name': instance.reporterUserName,
      'reporter_user_uid': instance.reporterUserUid,
      'reported_user_name': instance.reportedUserName,
      'reported_user_uid': instance.reportedUserUid,
      'report_reason': instance.reportReason,
      'report_content_id': instance.reportContentId,
      'created_at': instance.date.toIso8601String(),
    };
