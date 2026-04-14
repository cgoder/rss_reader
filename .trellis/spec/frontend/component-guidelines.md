# Component Guidelines

> How components are structured and managed in this Flutter project.

---

## Overview

This project uses Flutter widgets as the primary building blocks for UI components. Widgets are composable, immutable objects that define the view's configuration. The project follows Flutter's reactive programming paradigm with proper state management using StatefulWidget and Provider for business logic separation. Components should be reusable, properly typed, and handle their own interactions with the application's providers and services.

Questions answered:
- What component architecture do you use? Flutter widgets with Provider pattern for state management
- How do you handle data fetching? Using async/await with Provider pattern
- What are the naming conventions? PascalCase for widget classes, descriptive names
- How do you manage component state? StatefulWidget for local state, Provider for shared state

---

## Widget Patterns

All widgets should follow these patterns:

```dart
// feed_list_screen.dart - Example of a well-structured screen widget
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

    return Scaffold(
      appBar: AppBar(title: const Text('RSS订阅')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Content widgets
            Expanded(child: _buildContent(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(FeedProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.feeds.isEmpty) {
      return const Center(child: Text('没有订阅源'));
    }
    
    return ListView.builder(
      itemCount: provider.feeds.length,
      itemBuilder: (context, index) {
        final feed = provider.feeds[index];
        return FeedItemWidget(feed: feed);
      },
    );
  }
}
```

Rules for widgets:
- Use StatefulWidget for components that need to manage internal state
- Follow the separation of concerns: UI logic vs business logic
- Use Consumer or Selector widgets to subscribe to Provider changes
- Properly dispose of resources and listeners when widgets are disposed
- Follow Flutter's widget composition patterns for reusability

---

## Handling User Input and State

When creating dialogs or forms with user input, special attention must be paid to state management to avoid issues like disabled buttons:

```dart
// _AddFeedDialog - Properly managing state in dialogs with user input
class _AddFeedDialog extends StatefulWidget {
  final Future<void> Function(String url) onAddFeed;

  const _AddFeedDialog({required this.onAddFeed});

  @override
  _AddFeedDialogState createState() => _AddFeedDialogState();
}

class _AddFeedDialogState extends State<_AddFeedDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isInputValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final text = _controller.text.trim();
    setState(() {
      _isInputValid = text.isNotEmpty; // Update validity based on actual input
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加订阅源'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'RSS地址',
          hintText: '输入RSS源URL',
        ),
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          if (_isInputValid) {
            _addFeedAndClose();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _isInputValid ? _addFeedAndClose : null, // Properly bind to state
          child: const Text('添加'),
        ),
      ],
    );
  }

  Future<void> _addFeedAndClose() async {
    final url = _controller.text.trim();
    if (url.isNotEmpty) {
      Navigator.pop(context);
      await widget.onAddFeed(url);
    }
  }
}
```

Key patterns for user input:
- Use TextEditingController for text inputs to track changes
- Use setState() to update UI based on input changes
- Always dispose controllers to prevent memory leaks
- Bind UI state to actual input values, not static variables
- Listen to text changes to update dependent UI elements dynamically

---

## Naming Conventions

Widgets follow strict naming conventions:
- Widget class names use PascalCase (e.g., `FeedListScreen`, `ArticleCard`, `CustomButton`)
- Private widget classes are prefixed with underscore (e.g., `_AddFeedDialog`)
- Use descriptive names that clearly indicate the widget's purpose
- Avoid generic names like `CustomWidget` or `MyComponent`

Good examples:
- `FeedListScreen` - Screen showing a list of feeds
- `ArticleCard` - Widget displaying a single article
- `_AddFeedDialog` - Private dialog for adding feeds
- `SearchInput` - Input field for searching

---

## Common Mistakes

Common widget-related mistakes to avoid:
- Managing state with local variables instead of StatefulWidget
- Not properly binding UI elements to actual input values
- Creating dialogs with static validation instead of dynamic validation
- Forgetting to dispose of TextEditingControllers and other resources
- Not listening to input changes to update dependent UI elements
- Using imperative approaches instead of Flutter's reactive model
- Creating closures that capture values without proper rebuild triggers
- Not updating widget state when user input changes
- Passing empty strings as initial values to button enable conditions
- Forgetting to use setState() when updating widget state
