import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/api/mangadex_api.dart';
import '../../core/api/huntertoon_api.dart';
import '../../core/models/manga.dart';
import 'manga_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MangaDexApi _api = MangaDexApi();
  final HunterToonApi _hunterToonApi = HunterToonApi();

  late Future<List<Manga>> _mangaFuture;
  late Future<dynamic> _trendingFuture;

  @override
  void initState() {
    super.initState();
    _mangaFuture = _api.fetchPopularManga();
    _trendingFuture = _hunterToonApi.getTrending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Combo'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildTrendingSection()),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: _buildMangaGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    return FutureBuilder<dynamic>(
      future: _trendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          // إذا فشل التريند، نخبي القسم بدل ما نكسرو الصفحة
          return const SizedBox.shrink();
        }

        final data = snapshot.data;
        final List items = data is List ? data : (data['data'] ?? []);
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Text(
                'الأكثر تداولاً',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final title = item['title']?.toString() ?? '';
                  final coverUrl = item['coverUrl']?.toString() ??
                      item['cover']?.toString() ??
                      '';
                  return Container(
                    width: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: coverUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (c, u) =>
                                        Container(color: Colors.grey[300]),
                                    errorWidget: (c, u, e) =>
                                        const Icon(Icons.broken_image),
                                  )
                                : Container(color: Colors.grey[800]),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                'كل المانغا',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMangaGrid() {
    return FutureBuilder<List<Manga>>(
      future: _mangaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('خطأ: ${snapshot.error}')),
          );
        }
        final mangaList = snapshot.data ?? [];
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final manga = mangaList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MangaDetailScreen(manga: manga),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: manga.coverUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (c, u) =>
                              Container(color: Colors.grey[300]),
                          errorWidget: (c, u, e) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      manga.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
            childCount: mangaList.length,
          ),
        );
      },
    );
  }
}
