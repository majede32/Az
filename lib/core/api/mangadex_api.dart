import 'package:dio/dio.dart';
import '../models/manga.dart';
import '../models/chapter.dart';

class MangaDexApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.mangadex.org'));

  Future<List<Manga>> fetchPopularManga({int limit = 20}) async {
    final response = await _dio.get('/manga', queryParameters: {
      'limit': limit,
      'order[followedCount]': 'desc',
      'includes[]': 'cover_art',
      'contentRating[]': ['safe', 'suggestive'],
    });
    return _parseMangaList(response.data['data']);
  }

  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    final response = await _dio.get('/manga', queryParameters: {
      'title': query,
      'limit': limit,
      'includes[]': 'cover_art',
    });
    return _parseMangaList(response.data['data']);
  }

  List<Manga> _parseMangaList(List data) {
    return data.map((manga) {
      final coverRel = (manga['relationships'] as List).firstWhere(
        (r) => r['type'] == 'cover_art',
        orElse: () => null,
      );
      final coverFileName = coverRel?['attributes']?['fileName'] ?? '';
      return Manga.fromJson(manga, coverFileName);
    }).toList();
  }

  // يرجع فصول بالعربي إذا موجودة، وإلا بالإنجليزي كـ fallback
  Future<List<Chapter>> fetchChapters(String mangaId) async {
    final arChapters = await _fetchChaptersByLang(mangaId, 'ar');
    if (arChapters.isNotEmpty) return arChapters;
    return _fetchChaptersByLang(mangaId, 'en');
  }

  Future<List<Chapter>> _fetchChaptersByLang(
      String mangaId, String lang) async {
    final response = await _dio.get('/manga/$mangaId/feed', queryParameters: {
      'translatedLanguage[]': lang,
      'order[chapter]': 'asc',
      'limit': 100,
      'includes[]': 'scanlation_group',
    });
    final data = response.data['data'] as List;
    return data.map((c) => Chapter.fromJson(c)).toList();
  }

  // يرجع روابط صور صفحات الفصل
  Future<List<String>> fetchChapterPages(String chapterId) async {
    final response = await _dio.get('/at-home/server/$chapterId');
    final baseUrl = response.data['baseUrl'];
    final hash = response.data['chapter']['hash'];
    final data = List<String>.from(response.data['chapter']['data']);
    return data.map((fileName) => '$baseUrl/data/$hash/$fileName').toList();
  }
}
