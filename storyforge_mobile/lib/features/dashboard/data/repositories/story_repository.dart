import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../story/data/models/story_model.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return StoryRepository(dio);
});

class StoryRepository {
  final Dio _dio;

  StoryRepository(this._dio);

  Future<List<StoryModel>> getStories() async {
    final response = await _dio.get(ApiConstants.stories);
    final List<dynamic> data = response.data;
    return data.map((json) => StoryModel.fromJson(json)).toList();
  }

  Future<StoryModel> getStoryById(int id) async {
    final url = ApiConstants.getStoryDetail(id.toString());
    final response = await _dio.get(url);
    return StoryModel.fromJson(response.data);
  }

  Future<StoryModel> createStory({required String title, String? genre}) async {
    final response = await _dio.post(
      ApiConstants.stories,
      data: {
        'title': title,
        if (genre != null) 'genre': genre,
      },
    );
    return StoryModel.fromJson(response.data);
  }

  Future<void> deleteStory(int id) async {
    final url = ApiConstants.getStoryDetail(id.toString());
    await _dio.delete(url);
  }

  Future<void> startStory(int id) async {
    final url = '${ApiConstants.getStoryDetail(id.toString())}/start';
    await _dio.post(url);
  }
}
