import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// 알림 종류.
///
/// `@JsonValue` 는 `notification.type` 의 CHECK 제약과 **같은 문자열**이어야 한다.
/// 값을 늘릴 때 한쪽만 고치면, 모르는 값이 한 행이라도 섞이는 순간
/// 그 페이지 전체가 파싱에 실패해 "못 불러옴" 이 된다.
/// (`ReportContentType` 과 같은 종류의 결합이다)
enum NotificationType {
  @JsonValue('comment')
  comment('댓글을 남겼습니다.'),
  @JsonValue('board_like')
  boardLike('회원님의 글을 좋아합니다.');

  /// 목록에 보여줄 문구. 앞에 [NotificationModel.actorName] 이 붙는다.
  final String label;

  const NotificationType(this.label);
}

/// 인앱 알림 모델. Postgres `notification` 테이블의 행 1건에 대응한다.
///
/// **행은 서버 트리거만 만든다.** 앱에는 INSERT 권한이 없고 `is_read` 컬럼만
/// 수정할 수 있다 — 아무나 알림을 만들 수 있으면 그 자체가 사칭·스팸 통로다.
@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationModel implements ModelWithId {
  @override
  final String id;

  /// 무슨 일이 일어났는지. (댓글 / 좋아요)
  final NotificationType type;

  /// 행동한 사람의 표시 이름.
  ///
  /// 일어난 시점의 스냅샷이라 그 사람이 닉네임을 바꿔도 지난 알림은 그대로다.
  /// (게시글·댓글의 `user_name` 과 같은 이유 — `profile` 은 본인 행만 조회된다)
  final String actorName;

  /// 알림을 누르면 이동할 게시글 id.
  final String boardId;

  /// 게시글 제목. 목록마다 `board` 를 임베드하지 않으려고 비정규화해 둔 값이다.
  /// 원글 제목을 수정해도 지난 알림의 제목은 바뀌지 않는다.
  final String boardTitle;

  /// 댓글 내용 앞부분(50자). 좋아요 알림에는 없다.
  final String? preview;

  /// 읽음 여부. 안 읽은 개수가 종 아이콘의 배지가 된다.
  final bool isRead;

  /// 행 생성 시각. 컬럼명은 `created_at`, 정렬·커서의 기준이다.
  @JsonKey(name: 'created_at')
  final DateTime date;

  NotificationModel({
    required this.id,
    required this.type,
    required this.actorName,
    required this.boardId,
    required this.boardTitle,
    required this.isRead,
    required this.date,
    this.preview,
  });

  /// 읽음 표시만 세운 복사본.
  ///
  /// 탭한 즉시 강조를 걷어내기 위해 서버 왕복 전에 쓴다. (실패하면 되돌린다)
  NotificationModel asRead() => NotificationModel(
    id: id,
    type: type,
    actorName: actorName,
    boardId: boardId,
    boardTitle: boardTitle,
    isRead: true,
    date: date,
    preview: preview,
  );

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
