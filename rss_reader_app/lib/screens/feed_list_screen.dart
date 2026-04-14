import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../models/feed_model.dart';

class FeedListScreen extends StatefulWidget {
  const FeedListScreen({Key? key}) : super(key: key);

  @override
  State<FeedListScreen> createState() => _FeedListScreenState();
}

class _FeedListScreenState extends State<FeedListScreen> {
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FeedProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 添加订阅按钮
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('添加订阅源'),
            onPressed: _showAddFeedDialog,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          const SizedBox(height: 16),

          // 错误消息
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // 订阅列表
          Expanded(
            child: provider.feeds.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rss_feed,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '还没有添加任何订阅源\n点击上方按钮开始添加',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.refreshAllArticles(),
                    child: ListView.builder(
                      itemCount: provider.feeds.length,
                      itemBuilder: (context, index) {
                        final feed = provider.feeds[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              feed.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              feed.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFeed(context, feed.id),
                            ),
                            onTap: () {
                              // 点击后可以跳转到该订阅源的文章列表
                              // 或者执行其他操作
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddFeedDialog() async {
    String feedUrl = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加订阅源'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'RSS地址',
              hintText: '输入RSS源URL',
            ),
            onChanged: (value) {
              feedUrl = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: feedUrl.isEmpty
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _addFeed(feedUrl);
                    },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFeed(String url) async {
    final provider = Provider.of<FeedProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final success = await provider.addFeed(url);

      if (!success) {
        setState(() {
          _errorMessage = '无法添加订阅源，请检查URL是否有效';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '添加订阅源时发生错误: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeFeed(BuildContext context, String feedId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这个订阅源吗？\n相关的文章也会被移除。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<FeedProvider>(context, listen: false)
                    .removeFeed(feedId);
                Navigator.pop(context);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}