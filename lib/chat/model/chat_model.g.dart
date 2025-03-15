// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
      id: json['id'] as String,
      content: json['content'] as String,
      userName: json['userName'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'userName': instance.userName,
      'date': const TimestampConverter().toJson(instance.date),
      'imageUrl': instance.imageUrl,
    };
