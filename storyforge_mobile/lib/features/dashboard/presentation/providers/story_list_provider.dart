import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/story_repository.dart';
import '../../../story/data/models/story_model.dart';

final storyListProvider = AsyncNotifierProvider<StoryListNotifier, List<StoryModel>>(() {
  return StoryListNotifier();
});

class StoryListNotifier extends AsyncNotifier<List<StoryModel>> {
  @override
  FutureOr<List<StoryModel>> build() async {
    return _fetchStories();
  }

  Future<List<StoryModel>> _fetchStories() async {
    final repository = ref.read(storyRepositoryProvider);
    return repository.getStories();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStories());
  }

  Future<void> createStory(String title, String? genre) async {
    final repository = ref.read(storyRepositoryProvider);
    
    // We can't easily do optimistic update for creation because we don't have the ID yet,
    // but we can refresh the list after creation.
    state = await AsyncValue.guard(() async {
      await repository.createStory(title: title, genre: genre);
      return _fetchStories();
    });
  }

  Future<void> deleteStory(int id) async {
    final repository = ref.read(storyRepositoryProvider);
    
    final previousState = state.valueOrNull;
    if (previousState != null) {
      // Optimistic update
      state = AsyncValue.data(
        previousState.where((story) => story.id != id).toList(),
      );
    }

    try {
      await repository.deleteStory(id);
    } catch (e) {
      // Rollback on error
      if (previousState != null) {
        state = AsyncValue.data(previousState);
      }
      rethrow;
    }
  }
}
