// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardModel _$BoardModelFromJson(Map<String, dynamic> json) => BoardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      userName: json['userName'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
      commentList: (json['commentList'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BoardModelToJson(BoardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'userName': instance.userName,
      'date': const TimestampConverter().toJson(instance.date),
      'commentList': instance.commentList,
    };
