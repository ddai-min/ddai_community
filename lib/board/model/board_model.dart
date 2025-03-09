import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'board_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable(
  createToJson: false,
)
class BoardModel {
  final String title;
  final String content;
  final String userName;
  @TimestampConverter()
  final DateTime date;

  BoardModel({
    required this.title,
    required this.content,
    required this.userName,
    required this.date,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) =>
      _$BoardModelFromJson(json);
}
