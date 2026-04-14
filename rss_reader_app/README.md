# RSS Reader App

一个类似 bestblogs.dev 的轻量级RSS阅读器应用，使用Flutter开发，支持多平台编译。

## 功能特性

- 添加/删除RSS订阅源
- 文章列表按时间排序显示
- 文章收藏功能
- 关键字搜索功能
- 离线阅读支持
- 简洁易用的界面

## 技术栈

- Flutter: 跨平台开发框架
- Provider: 状态管理
- xml: RSS/Atom feed解析
- hive: 本地数据存储
- path_provider: 文件路径管理

## 安装与运行

1. 确保已安装Flutter SDK
2. 克隆项目
3. 运行 `flutter pub get` 安装依赖
4. 运行 `flutter run` 启动应用

## 项目结构

```
lib/
├── main.dart           # 应用入口
├── models/             # 数据模型
│   └── feed_model.dart
├── providers/          # 状态管理
│   └── feed_provider.dart
├── services/           # 业务逻辑服务
│   └── feed_service.dart
└── screens/            # 页面组件
    ├── home_screen.dart
    ├── article_list_screen.dart
    ├── feed_list_screen.dart
    └── article_detail_screen.dart
```

## 开发说明

本应用遵循极简设计原则，专注于核心的RSS阅读功能。主要功能包括：

1. **订阅管理**：用户可以添加和删除RSS订阅源
2. **文章浏览**：展示来自所有订阅源的文章，按时间排序
3. **收藏功能**：用户可以收藏喜欢的文章
4. **搜索功能**：支持基于关键字的文章搜索
5. **离线阅读**：文章会在本地缓存，支持离线访问