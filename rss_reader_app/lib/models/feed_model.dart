class FeedSource {
  final String id;
  final String title;
  final String url;
  final String? description;

  FeedSource({
    required this.id,
    required this.title,
    required this.url,
    this.description,
  });

  factory FeedSource.fromJson(Map<String, dynamic> json) {
    return FeedSource(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'description': description,
    };
  }
}

class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String link;
  final DateTime pubDate;
  final String feedId;
  final bool isFavorite;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.link,
    required this.pubDate,
    required this.feedId,
    this.isFavorite = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      link: json['link'] ?? '',
      pubDate: DateTime.parse(json['pubDate'] ?? DateTime.now().toIso8601String()),
      feedId: json['feedId'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'link': link,
      'pubDate': pubDate.toIso8601String(),
      'feedId': feedId,
      'isFavorite': isFavorite,
    };
  }
}