
import 'package:bookreader/util/html_util.dart';

class Chapter {
  int id;
  final String name;
  final String url;

  Chapter(this.name, this.url);
}

class ChapterContent {
  final String name;
  final String url;
  final String content;
  final String nextUrl;
  final String prevUrl;

  ChapterContent(this.name, this.url, this.content, this.nextUrl, this.prevUrl);

  String getContentHtml() {
    return content;
  }

  String getContent() {
    return HtmlUtil.htmlToString(content);
  }
}