// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: json['id'] as String,
  boardId: json['board_id'] as String,
  userName: json['user_name'] as String,
  userUid: json['user_uid'] as String,
  content: json['content'] as String,
  date: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'board_id': instance.boardId,
      'user_name': instance.userName,
      'user_uid': instance.userUid,
      'content': instance.content,
      'created_at': instance.date.toIso8601String(),
    };
