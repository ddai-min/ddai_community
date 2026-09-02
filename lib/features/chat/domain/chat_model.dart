import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

/// 채팅 메시지 모델. Postgres `chat` 테이블의 행에 대응한다.
@JsonSerializable(fieldRename: FieldRename.snake)
class ChatModel implements ModelWithId {
  @override
  final String id;
  final String content;
  final String userName;
  final String userUid;

  /// 행 생성 시각. 컬럼명은 `created_at`, 정렬·커서의 기준이다.
  @JsonKey(name: 'created_at')
  final DateTime date;

  ChatModel({
    required this.id,
    required this.content,
    required this.userName,
    required this.userUid,
    required this.date,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}
