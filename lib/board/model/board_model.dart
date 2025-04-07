import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/common/converter/timestamp_converter.dart';
import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'board_model.g.dart';

@JsonSerializable()
class BoardModel implements ModelWithId {
  @override
  final String id;
  final String title;
  final String content;
  final String userName;
  @TimestampConverter()
  final DateTime date;
  final List<CommentModel>? commentList;

  BoardModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userName,
    required this.date,
    this.commentList,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) =>
      _$BoardModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoardModelToJson(this);
}
