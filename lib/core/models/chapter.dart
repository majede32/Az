class Chapter {
  final String id;
  final String? chapterNumber;
  final String? title;
  final String translatedLanguage;

  Chapter({
    required this.id,
    this.chapterNumber,
    this.title,
    required this.translatedLanguage,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    return Chapter(
      id: json['id'],
      chapterNumber: attributes['chapter'],
      title: attributes['title'],
      translatedLanguage: attributes['translatedLanguage'] ?? '',
    );
  }
}
