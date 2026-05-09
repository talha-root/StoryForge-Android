import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/data/repositories/story_repository.dart';
import '../../data/models/story_model.dart';

final storyProvider = AsyncNotifierProviderFamily<StoryNotifier, StoryModel, int>(() {
  return StoryNotifier();
});

class StoryNotifier extends FamilyAsyncNotifier<StoryModel, int> {
  @override
  FutureOr<StoryModel> build(int arg) async {
    final repository = ref.read(storyRepositoryProvider);
    return repository.getStoryById(arg);
  }

  Future<void> startStory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(storyRepositoryProvider);
      await repository.startStory(arg);
      return repository.getStoryById(arg);
    });
  }
}
