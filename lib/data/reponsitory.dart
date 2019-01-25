
import 'dart:async';

import 'package:bookreader/data/truyencv.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:http/http.dart' as http;


const String TRUYENFULL = 'truyenfull.vn';
const String TRUYENCV = 'truyencv.com';
const String WIKIDICH = 'wikidich.com';

class DataRepon {
  static final String TAG = 'DataRepon';

  static final DataRepon _dataRepon = new DataRepon._internal();

  String sourceBook;
  int totalPage = 0;

  /// Factory constructor
  factory DataRepon() {
    return _dataRepon;
  }

  DataRepon._internal();

  /// Get list chapter of book
  Future<List<Chapter>> getListChapter(String url, int page) async {
    List<Chapter> listChap = [];

    try{
      Uri uri = Uri.parse(url);
      sourceBook = uri.host;
      switch(sourceBook) {
        case TRUYENCV:
          listChap = await TruyenCv().loadListChap(url, page);
          totalPage = await TruyenCv().getTotalPage();
          break;
        case TRUYENFULL:
          listChap = await TruyenCv().loadListChap(url, page);
          totalPage = await TruyenCv().getTotalPage();
          break;
        case WIKIDICH:
          listChap = await TruyenCv().loadListChap(url, page);
          totalPage = await TruyenCv().getTotalPage();
          break;
      }
    } catch(e) {
      // Loi url
      Log.e(TAG + ' - getListChapter()', e.toString());
    }
    Log.d(TAG, 'Total page = $totalPage');
    return listChap;
  }
}
























