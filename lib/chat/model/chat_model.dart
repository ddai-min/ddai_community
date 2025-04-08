import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/converter/timestamp_converter.dart';
import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

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
