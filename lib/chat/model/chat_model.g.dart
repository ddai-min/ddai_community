// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
      id: json['id'] as String,
      content: json['content'] as String,
      userName: json['userName'] as String,
      userUid: json['userUid'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
    );

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'userName': instance.userName,
      'userUid': instance.userUid,
      'date': const TimestampConverter().toJson(instance.date),
    };
