import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_message.freezed.dart';
part 'story_message.g.dart';

@freezed
class StoryMessage with _$StoryMessage {
  const factory StoryMessage({
    @JsonKey(name: 'author_type', defaultValue: 'user') required String role,
    required String content,
    @JsonKey(name: 'created_at') required DateTime timestamp,
  }) = _StoryMessage;

  factory StoryMessage.fromJson(Map<String, dynamic> json) => _$StoryMessageFromJson(json);
}
