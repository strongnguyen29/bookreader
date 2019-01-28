import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/data/truyencv.dart';
import 'package:bookreader/data/truyenfull.dart';
import 'package:bookreader/data/wikidich.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

void main() {
  test('Test REPO', () async {
    String url = 'https://truyencv.com/thien-dao-thu-vien/';
    String url2 = 'https://truyenfull.vn/choc-tuc-vo-yeu-mua-mot-tang-mot-full/';
    String url3 = 'https://wikidich.com/truyen/quy-de-cuong-the-an-choi-trac-tang-dai-t-WQvPOe8h7C3~MnRg';
    var list = await WikiDich().loadListChap(url3, 1);
    for(Chapter chapter in list) {
      print(chapter.name);
      print(chapter.url);
    }

  });
}