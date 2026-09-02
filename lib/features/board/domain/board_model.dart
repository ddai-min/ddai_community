import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:ddai_community/features/board/domain/comment_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'board_model.g.dart';

/// 게시글 모델. Postgres `board` 테이블의 행 1건에 대응한다.
@JsonSerializable(fieldRename: FieldRename.snake)
class BoardModel implements ModelWithId {
  @override
  final String id;
  final String title;
  final String content;

  /// 작성자 표시 이름.
  final String userName;

  /// 작성자 uid. 본인 여부 판별·차단 필터링에 사용된다.
  final String userUid;

  /// 행 생성 시각. 컬럼명은 `created_at`, 정렬·커서의 기준이다.
  @JsonKey(name: 'created_at')
  final DateTime date;

  /// 상세 조회 시 함께 로딩되는 댓글 목록. 목록 조회에서는 null 이다.
  ///
  /// `select('*, comment(*)')` 로 임베딩하면 FK 관계 이름인 `comment` 키로 들어온다.
  @JsonKey(name: 'comment')
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
