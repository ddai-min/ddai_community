import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

/// 댓글 모델. Postgres `comment` 테이블의 행에 대응한다.
/// Firestore 의 하위 컬렉션 대신 `board_id` FK 로 게시글에 매달린다.
@JsonSerializable(fieldRename: FieldRename.snake)
class CommentModel implements ModelWithId {
  @override
  final String id;
  final String userName;
  final String userUid;
  final String content;

  /// 행 생성 시각. 컬럼명은 `created_at`, 정렬·커서의 기준이다.
  @JsonKey(name: 'created_at')
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
