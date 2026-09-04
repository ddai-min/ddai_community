// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockUserModel _$BlockUserModelFromJson(Map<String, dynamic> json) =>
    BlockUserModel(
      blockedUid: json['blocked_uid'] as String,
      blockedUserName: json['blocked_user_name'] as String? ?? '',
      date: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$BlockUserModelToJson(BlockUserModel instance) =>
    <String, dynamic>{
      'blocked_uid': instance.blockedUid,
      'blocked_user_name': instance.blockedUserName,
      'created_at': instance.date.toIso8601String(),
    };
