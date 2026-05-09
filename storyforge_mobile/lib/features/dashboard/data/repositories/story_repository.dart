import 'package:storyforge_mobile/features/story/data/models/story_model.dart';

abstract class StoryRepository {
  Future<List<StoryModel>> getStories();
  // TODO: implement other story methods
}
