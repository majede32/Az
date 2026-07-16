import 'package:dio/dio.dart';
import '../models/manga.dart';

class MangaDexApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.mangadex.org'));

  Future<List<Manga>> fetchPopularManga({int limit = 20}) async {
    final response = await _dio.get('/manga', queryParameters: {
      'limit': limit,
      'order[followedCount]': 'desc',
      'includes[]': 'cover_art',
      'contentRating[]': ['safe', 'suggestive'],
    });

    final data = response.data['data'] as List;
    return data.map((manga) {
      final coverRel = (manga['relationships'] as List).firstWhere(
        (r) => r['type'] == 'cover_art',
        orElse: () => null,
      );
      final coverFileName = coverRel?['attributes']?['fileName'] ?? '';
      return Manga.fromJson(manga, coverFileName);
    }).toList();
  }

  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    final response = await _dio.get('/manga', queryParameters: {
      'title': query,
      'limit': limit,
      'includes[]': 'cover_art',
    });

    final data = response.data['data'] as List;
    return data.map((manga) {
      final coverRel = (manga['relationships'] as List).firstWhere(
        (r) => r['type'] == 'cover_art',
        orElse: () => null,
      );
      final coverFileName = coverRel?['attributes']?['fileName'] ?? '';
      return Manga.fromJson(manga, coverFileName);
    }).toList();
  }
}
