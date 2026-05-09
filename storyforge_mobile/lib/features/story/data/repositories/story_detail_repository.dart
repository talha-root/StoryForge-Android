import 'package:storyforge_mobile/features/story/data/models/story_model.dart';

abstract class StoryDetailRepository {
  Future<StoryModel> getStoryById(String id);
  // TODO: implement other story detail methods
}
