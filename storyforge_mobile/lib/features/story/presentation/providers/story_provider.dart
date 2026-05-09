import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storyforge_mobile/features/story/data/models/story_model.dart';

part 'story_provider.g.dart';

@riverpod
class StoryDetail extends _$StoryDetail {
  @override
  Future<StoryModel?> build(String id) async {
    // TODO: implement fetch story by id
    return null;
  }
}
