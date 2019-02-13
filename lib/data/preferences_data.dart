import 'dart:async';
import 'dart:convert';

import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/model/replace_text.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

const PREFS_READING_CHAPTER = '_reading_chapter';
const PREFS_READING_SPEECH = '_reading_speech_pos';
const PREFS_CURRENT_PAGE = '_current_page';
const PREFS_REPLACE_TEXT = 'replace_texts';
const PREFS_BOOK_URLS = 'prefs_book_urls';


class PreferencesData {
  static final String TAG = 'PreferencesData';
  static final PreferencesData _preferencesData = new PreferencesData._internal();

  /// Factory constructor
  factory PreferencesData() {
    return _preferencesData;
  }

  PreferencesData._internal();

  /// Lưu vi tri dang doc;
  saveReadingSpeechPos(String bookUrl, int pos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(bookUrl + PREFS_READING_SPEECH, pos);
    Log.d(TAG, '_saveReadingSpeechPos currentSpeak = $pos');
  }

  saveReadingChapter(String bookUrl, String chapName, String chapUrl) async {
    List<String> list = [chapName, chapUrl];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(bookUrl + PREFS_READING_CHAPTER, list);
    Log.d(TAG, '_saveReadingChapter name = $chapName');
  }


  /// Luu thuoc tinh
  saveReaderProperty(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(value is double) {
      prefs.setDouble(key, value);
    } else if(value is String) {
      prefs.setString(key, value);
    }

    Log.d(TAG, '_saveReaderStyle: $key : $value');
  }

  /// Luu trang ds chuong hien tai
  void saveCurrentPage(String bookUrl, int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(bookUrl + PREFS_CURRENT_PAGE, page);
    Log.d(TAG, '_saveCurrentPage page = $page');
  }

  /// Load list replace text;
  Future<List<ReplaceText>> getListReplace() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonText = prefs.getString('replace_texts') ?? null;

    if(jsonText == null) return null;

    List<dynamic> parserJson = json.decode(jsonText);

    if(parserJson == null || parserJson.length == 0) return null;

    return parserJson.map((i)=>ReplaceText.fromJson(i)).toList();
  }

  /// Save list replace text;
  saveListReplace(List<ReplaceText> list) async {
    // Convert list text to json;
    String js = '[';
    for(int i = 0; i < list.length; i++) {
      if(i != 0) js += ',';
      js += jsonEncode(list[i]);
    }
    js += ']';
    // save to memory
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PREFS_REPLACE_TEXT, js);
    Log.d(TAG, "_saveListReplace: $js");
  }

  /// Luu danh sach url da doc
  saveListUrls(List<String> listUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(PREFS_BOOK_URLS, listUrl);
  }

  /// Get chapter reading info
  Future<Chapter> getReadingChapter(String bookUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(bookUrl + PREFS_READING_CHAPTER) ?? null;
    if(list != null && list.length >= 2) {
      return new Chapter(list[0], list[1]);
    }
    return null;
  }

  /// Get current page
  Future<int> getCurrentPage(String bookUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(bookUrl + PREFS_CURRENT_PAGE) ?? 1;
  }

  /// Lay danh sach url da doc
  Future<List<String>> loadListUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> urls = prefs.getStringList(PREFS_BOOK_URLS);
    return urls;
  }
}