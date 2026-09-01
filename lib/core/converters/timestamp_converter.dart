import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Firestore 의 [Timestamp] 와 Dart 의 [DateTime] 을 상호 변환하는 컨버터.
///
/// 모델 필드에 `@TimestampConverter()` 를 붙이면 json_serializable 이
/// 직렬화/역직렬화 시 이 변환을 자동으로 적용한다.
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
