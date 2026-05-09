import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storyforge_mobile/features/story/data/models/story_model.dart';

part 'story_list_provider.g.dart';

@riverpod
class StoryList extends _$StoryList {
  @override
  Future<List<StoryModel>> build() async {
    // TODO: implement fetch stories
    return [];
  }
}
