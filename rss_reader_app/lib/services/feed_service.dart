import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;
import '../models/feed_model.dart';

class FeedService {
  static const String _feedsFileName = 'feeds.json';
  static const String _favoritesFileName = 'favorites.json';

  // 解析RSS源
  Future<FeedSource?> parseFeedUrl(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final document = xml.XmlDocument.parse(responseBody);

        // 查找feed标题
        var titleElement = document.findAllElements('title').firstWhere(
          (element) => element.parentElement?.name.local == 'channel' ||
                      element.parentElement?.name.local == 'feed',
          orElse: () => document.findAllElements('title').firstWhere(
            (element) => !['atom:title', 'category', 'author', 'contributor'].contains(element.name.local),
            orElse: () => xml.XmlElement(xml.XmlName('title'), [], [xml.XmlText('Unknown Feed')]),
          ),
        );

        // 查找feed描述
        var descElement = document.findAllElements('description').firstWhere(
          (element) => element.parentElement?.name.local == 'channel',
          orElse: () => xml.XmlElement(xml.XmlName('description'), []),
        );

        final feedTitle = titleElement.text.trim();
        final feedDescription = descElement.text.trim();

        // 生成唯一ID
        final feedId = url.hashCode.toString();

        return FeedSource(
          id: feedId,
          title: feedTitle.isNotEmpty ? feedTitle : 'Unknown Feed',
          url: url,
          description: feedDescription.isNotEmpty ? feedDescription : null,
        );
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error parsing feed: $e');
      return null;
    }
  }

  // 获取文章列表
  Future<List<Article>> fetchArticlesForFeed(String feedId) async {
    try {
      // 获取订阅源
      final feeds = await getSavedFeeds();
      final feed = feeds.firstWhere((f) => f.id == feedId, orElse: () =>
        FeedSource(id: '', title: '', url: '', description: '')
      );

      if (feed.url.isEmpty) {
        return [];
      }

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(feed.url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final document = xml.XmlDocument.parse(responseBody);

        final items = <Article>[];

        // 尝试从RSS和Atom格式中提取文章
        final entryElements = document.findAllElements('item') +
            document.findAllElements('entry');

        for (final item in entryElements) {
          try {
            // 提取标题
            String title = '';
            final titleElements = item.findAllElements('title');
            if (titleElements.isNotEmpty) {
              title = titleElements.first.text.trim();
            }

            // 提取描述/内容
            String description = '';
            final descriptionElements = item.findAllElements('description') +
                item.findAllElements('summary') +
                item.findAllElements('content');
            if (descriptionElements.isNotEmpty) {
              description = descriptionElements.first.text.trim();
            }

            // 提取链接
            String link = '';
            final linkElements = item.findAllElements('link');
            if (linkElements.isNotEmpty) {
              // 对于RSS，链接通常是元素的text，对于Atom，可能在href属性中
              link = linkElements.first.getAttribute('href') ??
                     linkElements.first.getAttribute('url') ??
                     linkElements.first.text;

              if (link.isEmpty && linkElements.length > 1) {
                link = linkElements.elementAt(1).text;
              }
            }

            // 提取发布日期
            DateTime pubDate = DateTime.now();
            final dateElements = item.findAllElements('pubDate') +
                item.findAllElements('published') +
                item.findAllElements('updated');
            if (dateElements.isNotEmpty) {
              try {
                pubDate = DateTime.parse(dateElements.first.text.trim());
              } catch (e) {
                // 如果无法解析日期，使用当前时间
                pubDate = DateTime.now();
              }
            }

            // 生成文章ID
            final articleId = '${feedId}_${link.hashCode}';

            if (title.isNotEmpty) {
              items.add(Article(
                id: articleId,
                title: title,
                description: description,
                content: description, // 在RSS中，description通常包含内容
                link: link,
                pubDate: pubDate,
                feedId: feedId,
              ));
            }
          } catch (e) {
            print('Error parsing article: $e');
            continue; // 继续处理下一个文章项
          }
        }

        return items;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching articles: $e');
      return [];
    }
  }

  // 保存订阅源到本地
  Future<void> saveFeeds(List<FeedSource> feeds) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, _feedsFileName));

    final feedJsonList = feeds.map((feed) => feed.toJson()).toList();
    await file.writeAsString(jsonEncode(feedJsonList));
  }

  // 获取已保存的订阅源
  Future<List<FeedSource>> getSavedFeeds() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(path.join(directory.path, _feedsFileName));

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);

        return jsonList.map((json) => FeedSource.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading feeds: $e');
    }
    return [];
  }

  // 添加订阅源
  Future<FeedSource?> addFeed(String url) async {
    final feedSource = await parseFeedUrl(url);
    if (feedSource != null) {
      final feeds = await getSavedFeeds();
      // 检查是否已经存在
      if (!feeds.any((feed) => feed.url == url)) {
        feeds.add(feedSource);
        await saveFeeds(feeds);
      }
      return feedSource;
    }
    return null;
  }

  // 移除订阅源
  Future<void> removeFeed(String feedId) async {
    final feeds = await getSavedFeeds();
    feeds.removeWhere((feed) => feed.id == feedId);
    await saveFeeds(feeds);
  }

  // 添加收藏文章
  Future<void> addToFavorites(Article article) async {
    final favorites = await getFavoriteArticles();
    // 检查是否已经收藏
    if (!favorites.any((fav) => fav.id == article.id)) {
      favorites.add(article);
      await _saveFavorites(favorites);
    }
  }

  // 从收藏中移除
  Future<void> removeFromFavorites(String articleId) async {
    final favorites = await getFavoriteArticles();
    favorites.removeWhere((article) => article.id == articleId);
    await _saveFavorites(favorites);
  }

  // 获取收藏文章
  Future<List<Article>> getFavoriteArticles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(path.join(directory.path, _favoritesFileName));

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);

        return jsonList.map((json) => Article.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
    return [];
  }

  // 保存收藏文章
  Future<void> _saveFavorites(List<Article> favorites) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, _favoritesFileName));

    final favoriteJsonList = favorites.map((article) => article.toJson()).toList();
    await file.writeAsString(jsonEncode(favoriteJsonList));
  }
}