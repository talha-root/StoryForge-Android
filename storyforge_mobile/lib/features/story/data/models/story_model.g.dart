// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryModelImpl _$$StoryModelImplFromJson(Map<String, dynamic> json) =>
    _$StoryModelImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      genre: json['genre'] as String?,
      status: json['status'] as String,
      ownerId: (json['owner_id'] as num?)?.toInt(),
      currentTurn: (json['current_turn'] as num?)?.toInt(),
      currentTurnUsername: json['current_turn_username'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessage: json['last_message'] as String?,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => StoryMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$StoryModelImplToJson(_$StoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'genre': instance.genre,
      'status': instance.status,
      'owner_id': instance.ownerId,
      'current_turn': instance.currentTurn,
      'current_turn_username': instance.currentTurnUsername,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_message': instance.lastMessage,
      'segments': instance.segments,
    };
