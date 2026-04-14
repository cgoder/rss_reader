import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../models/feed_model.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FeedProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.star,
              color: provider.isFavorite(article.id) ? Colors.orange : Colors.white,
            ),
            onPressed: () {
              provider.toggleFavorite(article);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文章标题
              Text(
                article.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // 发布时间和来源
              Row(
                children: [
                  Text(
                    '${article.pubDate.year}-${article.pubDate.month.toString().padLeft(2, '0')}-${article.pubDate.day.toString().padLeft(2, '0')} ${article.pubDate.hour.toString().padLeft(2, '0')}:${article.pubDate.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () {
                      // 在浏览器中打开原文链接
                      // 这里可以使用url_launcher包来打开链接
                    },
                  ),
                ],
              ),
              const Divider(height: 24),

              // 文章内容
              SelectableText(
                article.content.isNotEmpty ? article.content : article.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}