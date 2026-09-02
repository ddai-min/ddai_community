// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardModel _$BoardModelFromJson(Map<String, dynamic> json) => BoardModel(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  userName: json['user_name'] as String,
  userUid: json['user_uid'] as String,
  date: DateTime.parse(json['created_at'] as String),
  commentList: (json['comment'] as List<dynamic>?)
      ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BoardModelToJson(BoardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'user_name': instance.userName,
      'user_uid': instance.userUid,
      'created_at': instance.date.toIso8601String(),
      'comment': instance.commentList,
    };
