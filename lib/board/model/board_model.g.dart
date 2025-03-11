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
      imageUrl: json['imageUrl'] as String?,
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
      'imageUrl': instance.imageUrl,
      'commentList': instance.commentList,
    };

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'content': instance.content,
      'date': const TimestampConverter().toJson(instance.date),
      'imageUrl': instance.imageUrl,
    };
