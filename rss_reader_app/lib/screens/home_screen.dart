import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../models/feed_model.dart';
import 'feed_list_screen.dart';
import 'article_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  final List<Widget> _screens = [
    const ArticleListScreen(),
    const FeedListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? (_searchQuery.isEmpty
                ? const Text('RSS阅读器')
                : TextField(
                    decoration: const InputDecoration(
                      hintText: '搜索文章...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      // 更新ArticleListScreen中的搜索查询
                      if (_selectedIndex == 0) {
                        final provider = Provider.of<FeedProvider>(context, listen: false);
                        // 搜索功能将在ArticleListScreen中处理
                      }
                    },
                  ))
            : const Text('订阅管理'),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: Icon(_searchQuery.isEmpty ? Icons.search : Icons.clear),
                  onPressed: () {
                    setState(() {
                      if (_searchQuery.isEmpty) {
                        // 进入搜索模式
                      } else {
                        // 清空搜索
                        _searchQuery = '';
                      }
                    });
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'refresh') {
                      Provider.of<FeedProvider>(context, listen: false)
                          .refreshAllArticles();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'refresh',
                        child: Text('刷新'),
                      ),
                    ];
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: '文章',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rss_feed),
            label: '订阅',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 0) {
              _searchQuery = '';
            }
          });
        },
      ),
    );
  }
}