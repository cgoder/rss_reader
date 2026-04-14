import 'package:flutter/foundation.dart';
import '../models/feed_model.dart';
import '../services/feed_service.dart';

class FeedProvider with ChangeNotifier {
  final FeedService _feedService = FeedService();

  List<FeedSource> _feeds = [];
  List<Article> _articles = [];
  List<Article> _favorites = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<FeedSource> get feeds => _feeds;
  List<Article> get articles => _articles;
  List<Article> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // 获取所有文章并按时间排序
  List<Article> get sortedArticles {
    final sorted = List<Article>.from(_articles)..sort((a, b) => b.pubDate.compareTo(a.pubDate));
    return sorted;
  }

  // 初始化
  void initialize() async {
    await _loadFeeds();
    await _loadFavorites();
    notifyListeners();
  }

  // 加载订阅源
  Future<void> _loadFeeds() async {
    _feeds = await _feedService.getSavedFeeds();
  }

  // 加载收藏文章
  Future<void> _loadFavorites() async {
    _favorites = await _feedService.getFavoriteArticles();
  }

  // 添加订阅源
  Future<bool> addFeed(String url) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final feedSource = await _feedService.addFeed(url);
      if (feedSource != null) {
        _feeds.add(feedSource);
        await _refreshArticlesForFeed(feedSource.id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '无法添加订阅源，请检查URL是否有效';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '添加订阅源时出错: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 删除订阅源
  Future<void> removeFeed(String feedId) async {
    _feeds.removeWhere((feed) => feed.id == feedId);
    _articles.removeWhere((article) => article.feedId == feedId);
    await _feedService.removeFeed(feedId);
    notifyListeners();
  }

  // 刷新特定订阅源的文章
  Future<void> _refreshArticlesForFeed(String feedId) async {
    try {
      final newArticles = await _feedService.fetchArticlesForFeed(feedId);
      // 移除旧的文章（属于此feed的）
      _articles.removeWhere((article) => article.feedId == feedId);
      // 添加新文章
      _articles.addAll(newArticles);
    } catch (e) {
      _errorMessage = '刷新文章时出错: $e';
    }
  }

  // 刷新所有文章
  Future<void> refreshAllArticles() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      for (final feed in _feeds) {
        await _refreshArticlesForFeed(feed.id);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '刷新文章时出错: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 搜索文章
  List<Article> searchArticles(String query) {
    if (query.isEmpty) return sortedArticles;

    return _articles.where((article) {
      return article.title.toLowerCase().contains(query.toLowerCase()) ||
          article.description.toLowerCase().contains(query.toLowerCase());
    }).toList()..sort((a, b) => b.pubDate.compareTo(a.pubDate));
  }

  // 切换收藏状态
  Future<void> toggleFavorite(Article article) async {
    final existingIndex = _favorites.indexWhere((fav) => fav.id == article.id);

    if (existingIndex >= 0) {
      // 取消收藏
      _favorites.removeAt(existingIndex);
      await _feedService.removeFromFavorites(article.id);
    } else {
      // 添加收藏
      final favoriteArticle = Article(
        id: article.id,
        title: article.title,
        description: article.description,
        content: article.content,
        link: article.link,
        pubDate: article.pubDate,
        feedId: article.feedId,
        isFavorite: true,
      );
      _favorites.add(favoriteArticle);
      await _feedService.addToFavorites(favoriteArticle);
    }

    // 更新文章本身的收藏状态
    final articleIndex = _articles.indexWhere((a) => a.id == article.id);
    if (articleIndex >= 0) {
      _articles[articleIndex] = Article(
        id: article.id,
        title: article.title,
        description: article.description,
        content: article.content,
        link: article.link,
        pubDate: article.pubDate,
        feedId: article.feedId,
        isFavorite: existingIndex < 0, // 如果之前未收藏，则现在收藏
      );
    }

    notifyListeners();
  }

  // 获取收藏状态
  bool isFavorite(String articleId) {
    return _favorites.any((article) => article.id == articleId);
  }
}