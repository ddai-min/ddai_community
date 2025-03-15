import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/converter/timestamp_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  final String id;
  final String content;
  final String userName;
  @TimestampConverter()
  final DateTime date;
  final String? imageUrl;

  ChatModel({
    required this.id,
    required this.content,
    required this.userName,
    required this.date,
    this.imageUrl,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}
