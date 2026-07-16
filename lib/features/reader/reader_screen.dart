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

// عنصر واحد فالقائمة: إما فاصل بداية فصل، أو صفحة صورة
class _ReaderItem {
  final bool isChapterHeader;
  final String? imageUrl;
  final Chapter? chapter;

  _ReaderItem.header(this.chapter)
      : isChapterHeader = true,
        imageUrl = null;

  _ReaderItem.page(this.imageUrl)
      : isChapterHeader = false,
        chapter = null;
}

class _ReaderScreenState extends State<ReaderScreen> {
  final MangaDexApi _api = MangaDexApi();
  final ScrollController _scrollController = ScrollController();
  final List<_ReaderItem> _items = [];

  int _nextChapterIndex = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Chapter? _currentTopChapter;

  @override
  void initState() {
    super.initState();
    _nextChapterIndex = widget.initialIndex;
    _currentTopChapter = widget.chapters[widget.initialIndex];
    _loadNextChapter();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    final threshold = _scrollController.position.maxScrollExtent - 800;
    if (_scrollController.position.pixels >= threshold) {
      _loadNextChapter();
    }
  }

  Future<void> _loadNextChapter() async {
    if (_nextChapterIndex >= widget.chapters.length) {
      setState(() => _hasMore = false);
      return;
    }
    setState(() => _isLoadingMore = true);

    final chapter = widget.chapters[_nextChapterIndex];
    try {
      final pages = await _api.fetchChapterPages(chapter.id);
      setState(() {
        _items.add(_ReaderItem.header(chapter));
        _items.addAll(pages.map((url) => _ReaderItem.page(url)));
        _nextChapterIndex++;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _currentTopChapter != null
              ? 'الفصل ${_currentTopChapter!.chapterNumber ?? '?'}'
              : 'القراءة',
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == _items.length) {
            if (!_hasMore) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'وصلت لآخر فصل متاح',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = _items[index];

          if (item.isChapterHeader) {
            return Container(
              width: double.infinity,
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'الفصل ${item.chapter!.chapterNumber ?? '?'} ${item.chapter!.title ?? ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return CachedNetworkImage(
            imageUrl: item.imageUrl!,
            httpHeaders: const {'Referer': 'https://mangadex.org/'},
            fit: BoxFit.fitWidth,
            width: double.infinity,
            placeholder: (c, u) => Container(
              height: 400,
              color: Colors.grey[900],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (c, u, e) => Container(
              height: 200,
              color: Colors.grey[900],
              child: const Icon(Icons.broken_image, color: Colors.white54),
            ),
          );
        },
      ),
    );
  }
}
