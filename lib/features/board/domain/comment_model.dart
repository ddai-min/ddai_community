import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

/// 댓글 모델. Postgres `comment` 테이블의 행에 대응한다.
/// Firestore 의 하위 컬렉션 대신 `board_id` FK 로 게시글에 매달린다.
@JsonSerializable(fieldRename: FieldRename.snake)
class CommentModel implements ModelWithId {
  @override
  final String id;

  /// 이 댓글이 달린 게시글 id.
  ///
  /// 게시글 상세에서는 이미 아는 값이지만, "내가 쓴 댓글" 목록에서 원글로
  /// 이동하려면 댓글 자신이 들고 있어야 한다.
  final String boardId;

  final String userName;
  final String userUid;
  final String content;

  /// 행 생성 시각. 컬럼명은 `created_at`, 정렬·커서의 기준이다.
  @JsonKey(name: 'created_at')
  final DateTime date;

  CommentModel({
    required this.id,
    required this.boardId,
    required this.userName,
    required this.userUid,
    required this.content,
    required this.date,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
