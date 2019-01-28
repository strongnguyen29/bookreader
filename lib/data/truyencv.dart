import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class TruyenCv {
  final String TAG = 'TruyenCv';
  final String URL_PAGE = "https://truyencv.com/";

  static final TruyenCv _truyencv = new TruyenCv._internal();

  List<Chapter> listChapFull;
  int totalPage = 0;
  String bookName;

  factory TruyenCv() {
    return _truyencv;
  }

  TruyenCv._internal();

  /// Get list chapter with page;
  Future<List<Chapter>> loadListChap(String url, int page) async {
    Log.d(TAG, 'Running loadListChap()');
    List<Chapter> listChap = [];

    if(listChapFull == null || listChapFull.length == 0) {
      // Chua co data, tien hanh tai data;
      listChapFull = await _loadListChapFull(url);
    }

    // Khong co du lieu;
    if(listChapFull.length == 0) return listChap;

    if (listChapFull.length <= page * 50) {
      // Tong so chuong <= 50;
      listChap.addAll(listChapFull.sublist((page - 1) * 50, listChapFull.length));
    } else {
      // Tong so chuong > 50;
      listChap.addAll(listChapFull.sublist((page - 1) * 50, page * 50));
    }

    return listChap;
  }

  /// Get total page chapter;
  int getTotalPage() {
    Log.d(TAG, 'Running getTotalPage()');
    if (totalPage > 0) return totalPage;

    if (listChapFull.length <= 50) {
      totalPage = 1;
    } else {
      int du = listChapFull.length % 50;
      totalPage = listChapFull.length ~/ 50;
      if (du > 0) {
        totalPage += 1;
      }
    }
    Log.d(TAG, 'list lengt = ' + listChapFull.length.toString());
    return totalPage;
  }

  /// Load list chapter from server;
  Future<List<Chapter>> _loadListChapFull(String url) async {
    Log.d(TAG, 'Running _loadListChapFull()');
    List<Chapter> listChap = [];
    // Load request post body;
    var response = await http.get(url);

    // Load failed;
    if(response.statusCode != 200) return listChap;

    // Convert string html to DOM obj
    var doc = dom.Document.html(response.body);
    // Get book name
    bookName = doc.querySelector('.truyencv-detail-info-block .col-info .title a').text;
    // Get value of request post;
    var element = doc.querySelector('a[aria-controls="truyencv-detail-chap"]');
    //Log.d(TAG, element.outerHtml);

    List<String> listBody = [];
    element.attributes.forEach((dynamic key, String str) {
      if(key.toString() == 'onclick') {

        if (str != null && str.length> 0) {
          str = str.replaceAll("showChapter", "");
          str = str.replaceAll("(", "");
          str = str.replaceAll(")", "");
          str = str.replaceAll("'", "");
          listBody = str.split(",");
        }
      }
    });

    Map<String, String> body = {
      'showChapter':'1',
      'media_id': listBody[0],
      'number':listBody[1],
      'page': listBody[2],
      'type':listBody[3]
    };

    // Start load list chapter
    response = await http.post(URL_PAGE + 'index.php', body: body);

    // Convert string html to DOM obj
    doc = dom.Document.html(response.body);

    doc.querySelectorAll('.item a').forEach((item) {
      //Log.d(TAG, item.outerHtml);
      String link;
      item.attributes.forEach((dynamic key, String value) {
        if(key.toString() == 'href') {
          link = value;
        }
      });
      Chapter chapter = new Chapter(item.text, link);
      listChap.add(chapter);
    });

    return listChap.reversed.toList();
  }

}