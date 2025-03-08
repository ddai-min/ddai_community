import 'package:json_annotation/json_annotation.dart';

part 'board_model.g.dart';

@JsonSerializable(
  createToJson: false,
)
class BoardModel {
  final String title;
  final String content;
  final String writer;
  final String date;

  BoardModel({
    required this.title,
    required this.content,
    required this.writer,
    required this.date,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) =>
      _$BoardModelFromJson(json);
}
