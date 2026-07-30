import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/converter/timestamp_converter.dart';
import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

/// 댓글 모델. Firestore `board/{boardId}/comment` 하위 컬렉션 문서에 대응한다.
@JsonSerializable()
class CommentModel implements ModelWithId {
  @override
  final String id;
  final String userName;
  final String userUid;
  final String content;
  @TimestampConverter()
  final DateTime date;

  CommentModel({
    required this.id,
    required this.userName,
    required this.userUid,
    required this.content,
    required this.date,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
