# Terminal RSS Reader Usage

## Overview
We've created a terminal-based RSS reader that can run without GUI. This complements the existing Flutter GUI application.

## Installation & Setup
1. Make sure you have Dart/Flutter SDK installed
2. Navigate to the `rss_reader_app` directory
3. Run `flutter pub get` to install dependencies

## Running the Terminal Application
```bash
# Get help
dart run bin/rss_reader_cli.dart help

# List sample feeds
dart run bin/rss_reader_cli.dart list

# Fetch a specific RSS feed
dart run bin/rss_reader_cli.dart fetch <RSS_FEED_URL>
```

## Examples
```bash
# Example 1: Fetch Hacker News RSS
dart run bin/rss_reader_cli.dart fetch https://news.ycombinator.com/rss

# Example 2: Fetch TechCrunch RSS
dart run bin/rss_reader_cli.dart fetch https://techcrunch.com/feed/
```

## Features
- Fetch and parse RSS feeds from any URL
- Display article titles, links, and publication dates
- Support for various RSS formats
- Command-line interface for terminal usage

## Files Added
- `lib/cli.dart`: Main CLI logic for RSS processing
- `bin/rss_reader_cli.dart`: Entry point for the command-line application
- Updated `pubspec.yaml`: Added http dependency for network requests

## Verification
All commands have been tested and verified to work in the terminal environment.