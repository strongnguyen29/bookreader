import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class WikiDich {
  final String TAG = 'WikiDich';
  final String URL_PAGE = "https://wikidich.com";

  static final WikiDich _wikiDich = new WikiDich._internal();

  String bookName;
  String bookId;
  int totalPage = 0;

  factory WikiDich() {
    return _wikiDich;
  }

  WikiDich._internal();

  /// Get list chapter with page;
  Future<List<Chapter>> loadListChap(String url, int page) async {
    Log.d(TAG, 'Running loadListChap()');
    // Load book info;
    await _loadBookInfo(url);

    List<Chapter> listChap = [];

    if(bookId == null || totalPage == 0 || page > totalPage) {
      // Load book info false or page > totalPage;
      return listChap;
    }

    // Build url get list chapter
    String urlAjax = URL_PAGE + "/book/index?";
    urlAjax += "&bookId=$bookId&size=50&start=" + ((page - 1)*50).toString();
    // Load data
    var response = await http.get(urlAjax);
    // IF Load false;
    if(response.statusCode != 200) return listChap;
    // IF Load success;
    var doc = dom.Document.html(response.body);
    doc.querySelectorAll(".chapter-name a").forEach((dom.Element elm) {
      String name = elm.text;
      String href = URL_PAGE + elm.attributes['href'];
      listChap.add(new Chapter(name, href));
    });
    return listChap;
  }

  /// Load content chapter;
  Future<ChapterContent> loadChapContent(String url) async {
    var response = await http.get(url);
    // Load false;
    if(response.statusCode != 200) return null;

    // Convert to DOM Obj
    var doc = dom.Document.html(response.body);

    // Get title, url chap
    String name = doc.querySelectorAll('.book-title')[1].text;
    String urlChap = url;

    // Get url pre chap
    String prevUrl, nextUrl;
    var prevElm = doc.getElementById("btnPreChapter");
    if (prevElm != null) {
      prevUrl = URL_PAGE + prevElm.attributes['href'];
    }
    // Get url next chap
    var nextElm = doc.getElementById("btnNextChapter");
    if (prevElm != null) {
      nextUrl = URL_PAGE + nextElm.attributes['href'];
    }
    // Get content html
    String content = doc.getElementById("bookContentBody").innerHtml;

    return new ChapterContent(name, urlChap, content, nextUrl, prevUrl);
  }

  /// Load book info
  Future<bool> _loadBookInfo(String url) async {
    Log.d(TAG, 'Running _loadBookInfo()');

    // Da co thong tin truyen
    if(bookId != null && totalPage > 0) return true;

    // Chua co thong tin => tai ve;
    var response = await http.get(url);
    if(response.statusCode != 200) {
      // Load page false;
      return false;
    }

    // Convert string html to DOM obj
    var doc = dom.Document.html(response.body);

    // get book id;
    bookId = doc.getElementById('bookId').attributes['value'];
    // get total page;
    var element = doc.querySelectorAll(".volume-list .pagination li a").last;
    int totalChap;
    if (element == null) {
      totalPage = 1;
      var elements = doc.querySelectorAll(".chapter-name");
      totalChap = elements.length;
    } else {
      int start = int.parse(element.attributes['data-start']);
      int size = int.parse(element.attributes['data-size']);
      totalChap = start + size;
    }
    totalPage = totalChap~/50;
    if (totalChap%50 > 0) totalPage += 1;

    // Get book name
    bookName = doc.querySelector('.cover-info h2').text;

    return true;
  }

}



