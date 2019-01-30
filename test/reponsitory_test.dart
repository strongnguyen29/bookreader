import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/data/truyencv.dart';
import 'package:bookreader/data/truyenfull.dart';
import 'package:bookreader/data/wikidich.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:test/test.dart';

void main() {
  /// TRUYEN CV TESTING
  test('Test Truyencv - load list chap', () async {
    String TAG = 'Truyencv';
    String url = 'https://truyencv.com/toan-cau-cao-vo/';
    var list = await TruyenCv().loadListChap(url, 1);
    for(Chapter chapter in list) {
      Log.d(TAG, chapter.name);
      Log.d(TAG, chapter.url);
    }
  });

  test('Test Truyencv - load content', () async {
    String TAG = 'Truyencv';
    String url = 'https://truyencv.com/toan-cau-cao-vo/chuong-746/';
    ChapterContent chap = await TruyenCv().loadChapContent(url);

    if(chap == null) Log.e(TAG, 'Result NULL');

    Log.d(TAG, chap.name);
    Log.d(TAG, chap.url);
    Log.d(TAG, chap.prevUrl);
    Log.d(TAG, chap.nextUrl);
    Log.d(TAG, chap.content);
    Log.d(TAG, chap.getContent());

  });


  /// WIKIDICH TESTING
  test('Test wikidich - load list chap', () async {
    String TAG = 'Wikidich';
    String url = 'https://wikidich.com/truyen/quy-de-cuong-the-an-choi-trac-tang-dai-t-WQvPOe8h7C3~MnRg';
    var list = await WikiDich().loadListChap(url, 1);
    for(Chapter chapter in list) {
      Log.d(TAG, chapter.name);
      Log.d(TAG, chapter.url);
    }
  });

  test('Test wikidich - load content', () async {
    String TAG = 'Wikidich';
    String url = 'https://wikidich.com/truyen/nghich-luu-2004/de-nhat-muoi-chuong-keo-kiet-mua-ban-nho-W4J8ZsQsRGN_Ht0d';
    ChapterContent chap = await WikiDich().loadChapContent(url);

    if(chap == null) Log.e(TAG, 'Result NULL');

    Log.d(TAG, chap.name);
    Log.d(TAG, chap.url);
    Log.d(TAG, chap.prevUrl);
    Log.d(TAG, chap.nextUrl);
    Log.d(TAG, chap.content);
    Log.d(TAG, chap.getContent());

  });



  /// TRUYEN FULL TESTING
  test('Test TruyenFull - load list chap', () async {
    String TAG = 'Wikidich';
    String url = 'https://truyenfull.vn/choc-tuc-vo-yeu-mua-mot-tang-mot-full/';

    var list = await TruyenFull().loadListChap(url, 1);
    for(Chapter chapter in list) {
      Log.d(TAG, chapter.name);
      Log.d(TAG, chapter.url);
    }
  });

  test('Test TruyenFull - load content', () async {
    String TAG = 'TruyenFull';
    String url = 'https://truyenfull.vn/vu-dong-can-khon/chuong-506/';
    ChapterContent chap = await TruyenFull().loadChapContent(url);

    if(chap == null) Log.e('TruyenFull', 'Result NULL');

    Log.d('Truyen Full', chap.name);
    Log.d('Truyen Full', chap.url);
    Log.d('Truyen Full', chap.prevUrl);
    Log.d('Truyen Full', chap.nextUrl);
    Log.d('Truyen Full', chap.content);
    Log.d('Truyen Full', chap.getContent());

  });
}