import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/api/mangadex_api.dart';
import '../../core/models/chapter.dart';

class ReaderScreen extends StatefulWidget {
  final List<Chapter> chapters;
  final int initialIndex;

  const ReaderScreen({
    super.key,
    required this.chapters,
    required this.initialIndex,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final MangaDexApi _api = MangaDexApi();
  late int _currentIndex;
  late Future<List<String>> _pagesFuture;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadPages();
  }

  void _loadPages() {
    final chapter = widget.chapters[_currentIndex];
    _pagesFuture = _api.fetchChapterPages(chapter.id);
  }

  void _goToChapter(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.chapters.length) return;
    setState(() {
      _currentIndex = newIndex;
      _loadPages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapters[_currentIndex];
    final hasNext = _currentIndex < widget.chapters.length - 1;
    final hasPrev = _currentIndex > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('الفصل ${chapter.chapterNumber ?? '?'}'),
      ),
      body: FutureBuilder<List<String>>(
        future: _pagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطأ: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final pages = snapshot.data ?? [];
          return PageView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: pages[index],
                  fit: BoxFit.contain,
                  placeholder: (c, u) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (c, u, e) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: hasPrev ? () => _goToChapter(_currentIndex - 1) : null,
              icon: const Icon(Icons.arrow_back_ios),
              label: const Text('الفصل السابق'),
            ),
            TextButton.icon(
              onPressed: hasNext ? () => _goToChapter(_currentIndex + 1) : null,
              icon: const Icon(Icons.arrow_forward_ios),
              label: const Text('الفصل التالي'),
            ),
          ],
        ),
      ),
    );
  }
}
