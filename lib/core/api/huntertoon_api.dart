import 'package:dio/dio.dart';

class HunterToonApi {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.huntertoon.org/api/v1/',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  Future<dynamic> getTrending() async {
    try {
      final response = await _dio.get('trending');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load trending: $e');
    }
  }

  Future<dynamic> getLeaderboard() async {
    try {
      final response = await _dio.get('leaderboard');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load leaderboard: $e');
    }
  }
}
