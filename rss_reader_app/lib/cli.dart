import 'dart:io';
import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class CliRssReader {
  static Future<void> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      print('Usage: dart run bin/rss_reader_cli.dart <command> [options]');
      print('');
      print('Commands:');
      print('  fetch <url>     Fetch and display RSS feed');
      print('  list            List sample feeds');
      print('  help            Show this help message');
      return;
    }

    final command = arguments[0];

    switch (command) {
      case 'fetch':
        if (arguments.length < 2) {
          print('Error: Please provide a URL for the fetch command');
          return;
        }
        await _fetchFeed(arguments[1]);
        break;

      case 'list':
        _listSampleFeeds();
        break;

      case 'help':
      case '--help':
        _showHelp();
        break;

      default:
        print('Unknown command: $command');
        _showHelp();
        break;
    }
  }

  static Future<void> _fetchFeed(String url) async {
    try {
      print('Fetching RSS feed from: $url');
      print('');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('Error: Failed to fetch RSS feed. Status code: ${response.statusCode}');
        return;
      }

      final XmlDocument document = XmlDocument.parse(response.body);
      final feedElements = document.findAllElements('title');

      print('Feed Title: ${document.findAllElements('title').first?.text ?? "Unknown"}');
      print('');

      final items = document.findAllElements('item');
      print('Articles (${items.length} found):');
      print('----------------------------------------');

      for (final item in items.take(10)) { // Show first 10 articles
        final title = item.getElement('title')?.text ?? "No title";
        final link = item.getElement('link')?.text ?? "No link";
        final pubDate = item.getElement('pubDate')?.text ?? "No publish date";

        print('Title: $title');
        print('Link: $link');
        print('Published: $pubDate');
        print('');
      }
    } catch (e) {
      print('Error processing RSS feed: $e');
    }
  }

  static void _listSampleFeeds() {
    print('Sample RSS Feeds:');
    print('');
    print('1. BBC News: https://feeds.bbci.co.uk/news/rss.xml');
    print('2. Reddit Frontpage: https://www.reddit.com/.rss');
    print('3. Hacker News: https://news.ycombinator.com/rss');
    print('4. TechCrunch: https://techcrunch.com/feed/');
    print('');
    print('To fetch a feed: dart run bin/rss_reader_cli.dart fetch <url>');
  }

  static void _showHelp() {
    print('Terminal-based RSS Reader');
    print('');
    print('Usage: dart run bin/rss_reader_cli.dart <command> [options]');
    print('');
    print('Commands:');
    print('  fetch <url>     Fetch and display RSS feed from the given URL');
    print('  list            List sample feeds you can try');
    print('  help            Show this help message');
    print('');
    print('Example:');
    print('  dart run bin/rss_reader_cli.dart list');
    print('  dart run bin/rss_reader_cli.dart fetch https://feeds.bbci.co.uk/news/rss.xml');
  }
}