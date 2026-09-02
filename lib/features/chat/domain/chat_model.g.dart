// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
  id: json['id'] as String,
  content: json['content'] as String,
  userName: json['user_name'] as String,
  userUid: json['user_uid'] as String,
  date: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'user_name': instance.userName,
  'user_uid': instance.userUid,
  'created_at': instance.date.toIso8601String(),
};
