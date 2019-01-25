
class Chapter {
  int id;
  final String name;
  final String url;

  Chapter(this.name, this.url);
}

class ChapterContent {
  final Chapter chapter;
  final String content;
  final String nextUrl;
  final String prevUrl;

  ChapterContent(this.chapter, this.content, this.nextUrl, this.prevUrl);
}