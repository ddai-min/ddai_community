import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/board/model/comment_model.dart';
import 'package:ddai_community/common/converter/timestamp_converter.dart';
import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'board_model.g.dart';

/// 게시글 모델. Firestore `board` 컬렉션의 문서 1건에 대응한다.
@JsonSerializable()
class BoardModel implements ModelWithId {
  @override
  final String id;
  final String title;
  final String content;

  /// 작성자 표시 이름.
  final String userName;

  /// 작성자 uid. 본인 여부 판별·차단 필터링에 사용된다.
  final String userUid;
  @TimestampConverter()
  final DateTime date;

  /// 상세 조회 시 함께 로딩되는 댓글 목록. 목록 조회에서는 null 이다.
  final List<CommentModel>? commentList;

  BoardModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userName,
    required this.userUid,
    required this.date,
    this.commentList,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) =>
      _$BoardModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoardModelToJson(this);
}
