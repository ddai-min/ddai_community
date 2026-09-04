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

  /// 목록 조회에서만 채워지는 댓글 수. 상세 조회에서는 null 이다.
  ///
  /// 별칭을 붙여 `comment_count:comment(count)` 로 가져온다. 별칭 없이 `comment(count)`
  /// 를 쓰면 [commentList] 와 **같은 `comment` 키로 들어와** 목록 파싱이 깨진다.
  @JsonKey(
    name: 'comment_count',
    readValue: _readCommentCount,
    includeToJson: false,
  )
  final int? commentCount;

  /// 목록 조회에서만 채워지는 좋아요 수. 상세 조회에서는 null 이다.
  /// (상세는 내가 눌렀는지도 알아야 해서 `boardLikeProvider` 로 따로 조회한다)
  @JsonKey(
    name: 'like_count',
    readValue: _readCommentCount,
    includeToJson: false,
  )
  final int? likeCount;

  BoardModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userName,
    required this.userUid,
    required this.date,
    this.commentList,
    this.commentCount,
    this.likeCount,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) =>
      _$BoardModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoardModelToJson(this);
}

/// PostgREST 의 관계 집계는 `[{"count": 3}]` 형태로 온다.
///
/// 댓글 수와 좋아요 수가 같은 모양이라 하나로 쓴다.
/// 상세 조회처럼 이 별칭을 요청하지 않은 응답에서는 키 자체가 없어 null 이 된다.
Object? _readCommentCount(Map<dynamic, dynamic> json, String key) {
  final value = json[key];

  if (value is List && value.isNotEmpty) {
    final first = value.first;

    if (first is Map) {
      return first['count'];
    }
  }

  return null;
}
