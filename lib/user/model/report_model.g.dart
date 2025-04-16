// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
      id: json['id'] as String,
      reporterUserName: json['reporterUserName'] as String,
      reporterUserUid: json['reporterUserUid'] as String,
      reportedUserName: json['reportedUserName'] as String,
      reportedUserUid: json['reportedUserUid'] as String,
      reportReason: json['reportReason'] as String,
      reportContentId: json['reportContentId'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
    );

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporterUserName': instance.reporterUserName,
      'reporterUserUid': instance.reporterUserUid,
      'reportedUserName': instance.reportedUserName,
      'reportedUserUid': instance.reportedUserUid,
      'reportReason': instance.reportReason,
      'reportContentId': instance.reportContentId,
      'date': const TimestampConverter().toJson(instance.date),
    };
