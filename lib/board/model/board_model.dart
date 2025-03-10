import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/converter/timestamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'board_model.g.dart';

@JsonSerializable()
class BoardModel {
  final String id;
  final String title;
  final String content;
  final String userName;
  @TimestampConverter()
  final DateTime date;

  BoardModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userName,
    required this.date,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) =>
      _$BoardModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoardModelToJson(this);
}
