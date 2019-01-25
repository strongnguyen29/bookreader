import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/data/truyencv.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

void main() {
  test('Test REPO', () async {
    String url = 'https://truyencv.com/thien-dao-thu-vien/';
    print(url);
    //TruyenCv.getListChap(url);
  });
}