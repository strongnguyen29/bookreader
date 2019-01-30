
import 'dart:async';

import 'package:bookreader/data/truyencv.dart';
import 'package:bookreader/data/truyenfull.dart';
import 'package:bookreader/data/wikidich.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';


const String TRUYENFULL = 'truyenfull.vn';
const String TRUYENCV = 'truyencv.com';
const String WIKIDICH = 'wikidich.com';

class DataRepon {
  static final String TAG = 'DataRepon';

  static final DataRepon _dataRepon = new DataRepon._internal();

  String sourceBook;
  String bookName;
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
          bookName = TruyenCv().bookName;
          break;
        case TRUYENFULL:
          listChap = await TruyenFull().loadListChap(url, page);
          totalPage = TruyenFull().totalPage;
          bookName = TruyenFull().bookName;
          break;
        case WIKIDICH:
          listChap = await WikiDich().loadListChap(url, page);
          totalPage = WikiDich().totalPage;
          bookName = WikiDich().bookName;
          break;
      }
    } catch(e) {
      // Loi url
      Log.e(TAG + ' - getListChapter()', e.toString());
    }
    Log.d(TAG, 'Total page = $totalPage');
    return listChap;
  }

  Future<ChapterContent> getChapterContent(String url) async {

    try {
      Uri uri = Uri.parse(url);
      sourceBook = uri.host;
      switch(sourceBook) {
        case TRUYENCV:
          return await TruyenCv().loadChapContent(url);
        case TRUYENFULL:
          return await TruyenFull().loadChapContent(url);
          break;
        case WIKIDICH:
          return await WikiDich().loadChapContent(url);
          break;
      }
    } catch (e) {
      Log.e(TAG + ' - getChapterContent()', e.toString());
    }
    return null;
  }
}
























