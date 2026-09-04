import 'package:json_annotation/json_annotation.dart';

part 'block_user_model.g.dart';

/// 차단한 유저 1건. Postgres `block_user` 테이블의 행에 대응한다.
///
/// **`ModelWithId` 를 구현하지 않는다.** `block_user` 는 `(blocker_uid, blocked_uid)`
/// 복합 PK 라 `id` 컬럼이 없고, 그래서 `created_at desc, id desc` keyset 커서를 쓰는
/// `PaginationRepository` 를 탈 수 없다. 한 사람이 차단하는 인원은 많아야 수십 명이라
/// 목록을 한 번에 가져온다.
@JsonSerializable(fieldRename: FieldRename.snake)
class BlockUserModel {
  /// 차단당한 유저의 uid. 차단 해제의 키다.
  final String blockedUid;

  /// 차단할 당시 상대의 닉네임.
  ///
  /// `profile` 은 **본인 행만** 조회할 수 있어서 uid 로 이름을 되찾을 수 없다.
  /// 그래서 `board`/`chat` 의 `user_name` 과 같은 방식으로 비정규화해 두고,
  /// 값은 `BEFORE INSERT` 트리거(`private.set_blocked_user_name`)가 채운다.
  /// 상대가 나중에 닉네임을 바꿔도 여기 값은 그대로다.
  ///
  /// 비어 있을 수 있다 — 컬럼을 추가하기 전에 차단한 행, 또는 트리거가 이름을 찾지 못한
  /// 행이다. 이름이 없다고 차단 해제까지 못 하면 곤란하므로 파싱을 실패시키지 않고
  /// 화면이 대체 문구를 보여준다.
  @JsonKey(defaultValue: '')
  final String blockedUserName;

  @JsonKey(name: 'created_at')
  final DateTime date;

  BlockUserModel({
    required this.blockedUid,
    required this.blockedUserName,
    required this.date,
  });

  factory BlockUserModel.fromJson(Map<String, dynamic> json) =>
      _$BlockUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlockUserModelToJson(this);
}
