import 'package:freezed_annotation/freezed_annotation.dart';
import 'story_message.dart';

part 'story_model.freezed.dart';
part 'story_model.g.dart';

@freezed
class StoryModel with _$StoryModel {
  const factory StoryModel({
    required int id,
    required String title,
    String? genre,
    required String status,
    @JsonKey(name: 'owner_id') int? ownerId,
    @JsonKey(name: 'current_turn') int? currentTurn,
    @JsonKey(name: 'current_turn_username') String? currentTurnUsername,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'last_message') String? lastMessage,
    List<StoryMessage>? segments,
  }) = _StoryModel;

  factory StoryModel.fromJson(Map<String, dynamic> json) => _$StoryModelFromJson(json);
}
