import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/converter/timestamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String id;
  final String boardId;
  final String userName;
  final String content;
  @TimestampConverter()
  final DateTime date;

  CommentModel({
    required this.id,
    required this.boardId,
    required this.userName,
    required this.content,
    required this.date,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
