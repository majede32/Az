class Manga {
  final String id;
  final String title;
  final String? description;
  final String coverUrl;
  final List<String> tags;
  final String status;

  Manga({
    required this.id,
    required this.title,
    this.description,
    required this.coverUrl,
    required this.tags,
    required this.status,
  });

  factory Manga.fromJson(Map<String, dynamic> json, String coverFileName) {
    final attributes = json['attributes'];
    final titleMap = attributes['title'] as Map<String, dynamic>;
    final title = titleMap['en'] ?? titleMap.values.first;

    return Manga(
      id: json['id'],
      title: title,
      description: (attributes['description'] as Map?)?['en'],
      coverUrl:
          'https://uploads.mangadex.org/covers/${json['id']}/$coverFileName.256.jpg',
      tags: (attributes['tags'] as List)
          .map((t) => t['attributes']['name']['en'] as String)
          .toList(),
      status: attributes['status'] ?? 'unknown',
    );
  }
}
