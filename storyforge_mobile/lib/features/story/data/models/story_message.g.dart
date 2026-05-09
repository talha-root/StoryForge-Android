// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryMessageImpl _$$StoryMessageImplFromJson(Map<String, dynamic> json) =>
    _$StoryMessageImpl(
      role: json['author_type'] as String? ?? 'user',
      content: json['content'] as String,
      timestamp: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$StoryMessageImplToJson(_$StoryMessageImpl instance) =>
    <String, dynamic>{
      'author_type': instance.role,
      'content': instance.content,
      'created_at': instance.timestamp.toIso8601String(),
    };
