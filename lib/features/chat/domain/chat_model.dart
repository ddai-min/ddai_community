import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/core/converters/timestamp_converter.dart';
import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

/// 채팅 메시지 모델. Firestore `chat` 컬렉션 문서에 대응한다.
@JsonSerializable()
class ChatModel implements ModelWithId {
  @override
  final String id;
  final String content;
  final String userName;
  final String userUid;
  @TimestampConverter()
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
