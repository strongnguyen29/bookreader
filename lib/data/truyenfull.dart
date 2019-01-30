import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'dart:convert';

class TruyenFull {
  final String TAG = 'TruyenFull';
  final String URL_PAGE = "https://truyenfull.vn/";
  final int EXPIRES_HASH = 1800000; // 30 phut

  static final TruyenFull _truyenFull = new TruyenFull._internal();

  int timeGetHash;
  String hashKey;
  String bookName;
  int bookId = 0;
  int totalPage = 0;

  /// Constructor
  factory TruyenFull() {
    return _truyenFull;
  }

  TruyenFull._internal();

  /// Get list chapter with page;
  Future<List<Chapter>> loadListChap(String url, int page) async {
    Log.d(TAG, 'Running loadListChap()');

    // Load book info;
    await _loadBookInfo(url);
    // Load hash key
    await _loadHashKey();

    List<Chapter> listChap = [];

    if(bookId == 0 || totalPage == 0 || page > totalPage || hashKey == null) {
      // Load book info false or page > totalPage;
      return listChap;
    }

    // Build url get list chapter
    String urlAjax = URL_PAGE + "ajax.php?type=list_chapter";
    urlAjax += "&tid=$bookId&page=$page&totalp=$totalPage&hash=$hashKey";
    Log.d(TAG, 'Url ajax = $urlAjax');
    // Load data
    var response = await http.get(urlAjax);
    // Load false;
    if(response.statusCode != 200) return listChap;
    // Load success;

    Map<String, dynamic> map = json.decode(response.body);
    var doc = dom.Document.html(map['chap_list']);
    doc.querySelectorAll('.list-chapter li a').forEach((dom.Element elm) {
      listChap.add(new Chapter(
          elm.attributes['title'],
          _fixChapUrl(elm.attributes['href'], url)
      ));
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
    var titleElm = doc.querySelector('a.chapter-title');
    String name = titleElm.attributes['title'];
    String urlChap = titleElm.attributes['href'];

    // Get url pre chap
    String prevUrl, nextUrl;
    var prevElm = doc.getElementById("prev_chap");
    if (prevElm != null) {
      prevUrl = prevElm.attributes['href'];
    }
    // Get url next chap
    var nextElm = doc.getElementById("next_chap");
    if (prevElm != null) {
      nextUrl = nextElm.attributes['href'];
    }
    // Get content html
    String content = doc.querySelector(".chapter-c").innerHtml;

    return new ChapterContent(name, urlChap, content, nextUrl, prevUrl);
  }

  /// Get book info;
  Future<bool> _loadBookInfo(String url) async {
    Log.d(TAG, 'Running _loadBookInfo()');

    // Da co thong tin truyen
    if(bookId > 0 && totalPage > 0) return true;

    // Chua co thong tin => tai ve;
    var response = await http.get(url);
    if(response.statusCode != 200) {
      // Load page false;
      return false;
    }

    // Convert string html to DOM obj
    var doc = dom.Document.html(response.body);

    // get book id;
    bookId = int.parse(doc.getElementById('truyen-id').attributes['value']);
    // get total page;
    totalPage = int.parse(doc.getElementById('total-page').attributes['value']);
    // Get book name
    bookName = doc.querySelector('.col-info-desc .title').text;

    return true;
  }

  /// Get hash key use load ajax;
  Future<String> _loadHashKey() async {
    if (hashKey != null && new DateTime.now().millisecondsSinceEpoch - timeGetHash < EXPIRES_HASH) {
      // Đã có key, key chưa het han
      return hashKey;
    }

    String url = URL_PAGE + "ajax.php?type=hash";
    var response = await http.get(url);

    if(response.statusCode != 200) return null;

    var doc = dom.Document.html(response.body);
    hashKey = doc.querySelector("body").text;
    timeGetHash = new DateTime.now().millisecondsSinceEpoch;
    return hashKey;
  }

  /// Sua loi url thieu path truyen
  /// vd: https://truyenfull.vn//chuong-506/
  String _fixChapUrl(String chapUrl, String bookUrl) {
    String urlFix = chapUrl;
    try {
      // Get path book vd: vu-dong-can-khon
      Uri uriBook = Uri.parse(bookUrl);
      String pathBook = uriBook.path;
      pathBook = pathBook.replaceAll("/","");

      // Get path chuong vd: chuong-506
      Uri uri = Uri.parse(chapUrl);
      String path = uri.path;
      path = path.replaceAll("//", pathBook + "/");

      urlFix = URL_PAGE + path;
    } catch (e) {
      e.printStackTrace();
    }
    return urlFix;
  }
}