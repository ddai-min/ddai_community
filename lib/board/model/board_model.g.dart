// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardModel _$BoardModelFromJson(Map<String, dynamic> json) => BoardModel(
      title: json['title'] as String,
      content: json['content'] as String,
      userName: json['userName'] as String,
      date: const TimestampConverter().fromJson(json['date'] as Timestamp),
    );
