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
    readValue: _readCount,
    includeToJson: false,
  )
  final int? commentCount;

  /// 목록 조회에서만 채워지는 좋아요 수. 상세 조회에서는 null 이다.
  /// (상세는 내가 눌렀는지도 알아야 해서 `boardLikeProvider` 로 따로 조회한다)
  @JsonKey(
    name: 'like_count',
    readValue: _readCount,
    includeToJson: false,
  )
  final int? likeCount;

  /// 이 글을 본 사람 수. `board.view_count` 컬럼을 그대로 읽는다.
  ///
  /// 위의 두 개와 달리 **관계 집계가 아니라 진짜 컬럼**이다. 중복을 거르는 원장
  /// (`board_view`)은 앱이 읽을 수 없고, 서버의 `increment_board_view` RPC 가
  /// 그 안에서 중복을 걸러 이 값만 올린다. 그래서 한 사람이 몇 번을 다시 열어도
  /// 1 이고, 엄밀히는 "조회수" 가 아니라 **본 사람 수**다.
  ///
  /// 컬럼이 없는 응답(스키마 적용 전)에서는 null 이 되어 화면이 조용히 감춘다.
  final int? viewCount;

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
    this.viewCount,
  });

  /// 일부 필드만 교체한 사본을 반환한다. (불변 모델 갱신용)
  ///
  /// 목록 항목의 조회수처럼 **한 값만** 최신으로 갈아 끼울 때 쓴다.
  /// 넘기지 않은 필드는 그대로 유지되며, null 을 넣어 값을 지울 수는 없다.
  BoardModel copyWith({
    String? id,
    String? title,
    String? content,
    String? userName,
    String? userUid,
    DateTime? date,
    List<CommentModel>? commentList,
    int? commentCount,
    int? likeCount,
    int? viewCount,
  }) {
    return BoardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userName: userName ?? this.userName,
      userUid: userUid ?? this.userUid,
      date: date ?? this.date,
      commentList: commentList ?? this.commentList,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  factory BoardModel.fromJson(Map<String, dynamic> json) =>
      _$BoardModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoardModelToJson(this);
}

/// PostgREST 의 관계 집계는 `[{"count": 3}]` 형태로 온다.
///
/// 댓글 수와 좋아요 수가 같은 모양이라 하나로 쓴다.
/// 이 별칭을 요청하지 않은 응답에서는 키 자체가 없어 null 이 된다.
Object? _readCount(Map<dynamic, dynamic> json, String key) {
  final value = json[key];

  if (value is List && value.isNotEmpty) {
    final first = value.first;

    if (first is Map) {
      return first['count'];
    }
  }

  return null;
}
