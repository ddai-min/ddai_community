// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      actorName: json['actor_name'] as String,
      boardId: json['board_id'] as String,
      boardTitle: json['board_title'] as String,
      isRead: json['is_read'] as bool,
      date: DateTime.parse(json['created_at'] as String),
      preview: json['preview'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'actor_name': instance.actorName,
      'board_id': instance.boardId,
      'board_title': instance.boardTitle,
      'preview': instance.preview,
      'is_read': instance.isRead,
      'created_at': instance.date.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.comment: 'comment',
  NotificationType.boardLike: 'board_like',
};
