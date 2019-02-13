import 'dart:io';
import 'dart:math';

import 'package:bookreader/data/const.dart';
import 'package:bookreader/data/preferences_data.dart';
import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/model/style_reader.dart';
import 'package:bookreader/replace_text.dart';
import 'package:bookreader/util/FlutterTts.dart';
import 'package:bookreader/util/html_util.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ReaderPage extends StatefulWidget {
  final String bookUrl;
  final String bookName;
  final String chapUrl;
  final String chapName;
  final bool isResume;

  const ReaderPage({Key key, this.bookUrl, this.bookName, this.chapUrl, this.chapName, this.isResume}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ReaderState();
  }
}


/// Class State of page;
class ReaderState extends State<ReaderPage> {
  static const String TAG = 'ReaderState';
  static final String PREFS_STYLE_FONT =  'STYLES_font';
  static final String PREFS_STYLE_THEME =  'STYLES_theme';
  static final String PREFS_STYLE_SIZE =  'STYLES_size';
  static final String PREFS_STYLE_HEIGHT =  'STYLES_height';
  static final String PREFS_STYLE_PADDING =  'STYLES_padding';
  static final String PREFS_SPEECH_PITCH =  'TTS_pitch';
  static final String PREFS_SPEECH_SPEED=  'TTS_speed';

  // Scroll controller text view
  final ScrollController scrollController = new ScrollController();

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController<void> bottomSheetController;

  // Data reponsetory;
  DataRepon _dataRepon;
  PreferencesData preferencesData;

  // Content chap;
  String _chapUrl;
  String _chapName;
  String _chapContent = '';
  String _prevChapUrl;
  String _nextChapUrl;

  // Style reader
  StyleReader style;
  int select = 0;

  // Setting text to speech TTS;
  FlutterTts flutterTts;
  bool isSpeaking = false;
  double speechRate = 1.55;
  double pitch = 0.8;
  List<String> speechList = [];
  int currentSpeak = 0;

  bool _loading = false;
  bool _showStylePop = false;



  @override
  void initState() {
    super.initState();
    Log.d(TAG, 'initState');
    _dataRepon = new DataRepon();
    preferencesData = new PreferencesData();
    _chapUrl = widget.chapUrl;
    _chapName = widget.chapName ?? 'No name';

    style = StyleReader();
    getReaderPropertys();

    initTextToSpeech();

    loadChapterContent();
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    preferencesData.saveReadingSpeechPos(widget.bookUrl, currentSpeak);
  }

  /// Load chapter content;
  loadChapterContent() async {
    setState(() {
      _loading = true;
    });
    _dataRepon.getChapterContent(_chapUrl).then((result) {

      if(result == null) {
        setState(() => _loading == false);
        return;
      }

      setState(() {
        _loading = false;
        _chapName = result.name;
        _chapUrl = result.url;
        _chapContent = result.getContent();
        _nextChapUrl = result.nextUrl;
        _prevChapUrl = result.prevUrl;
      });
      speechList = _chapContent.split('\n');

      _applyReplaceText(false);

      if(isSpeaking) {
        _startSpeak();
      }

      preferencesData.saveReadingChapter(widget.bookUrl, _chapName, _chapUrl);
    });
  }


  /// Get thuoc tinh
  void getReaderPropertys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load style
    if(style == null) style = StyleReader();
    style.fontFamily = prefs.getString(PREFS_STYLE_FONT) ?? fontItems[0].value;
    style.textSize = prefs.getDouble(PREFS_STYLE_SIZE) ?? 20.0;
    Log.d(TAG, '_getReaderStyle style.textSize = ' + style.textSize.toString());
    style.lineHeight = prefs.getDouble(PREFS_STYLE_HEIGHT) ?? 1.2;
    style.lineHeight = _rounDouble(style.lineHeight, 1);
    Log.d(TAG, '_getReaderStyle style.lineHeight = ' + style.lineHeight.toString());
    style.paddingLR = prefs.getDouble(PREFS_STYLE_PADDING) ?? 24.0;
    Log.d(TAG, '_getReaderStyle style.paddingLR = ' + style.paddingLR.toString());
    String theme = prefs.getString(PREFS_STYLE_THEME) ?? 'dark';
    style.changeColor(theme);

    // Load speech propertys;
    pitch = prefs.getDouble(PREFS_SPEECH_PITCH) ?? 0.8;
    pitch = _rounDouble(pitch, 2);
    speechRate = prefs.getDouble(PREFS_SPEECH_SPEED) ?? 1.55;
    speechRate = _rounDouble(speechRate, 2);

    if(widget.isResume) {
      currentSpeak = prefs.getInt(widget.bookUrl + PREFS_READING_SPEECH) ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.d(TAG, 'build');
    return WillPopScope(
      onWillPop: () {
        var result = {'name' : _chapName, 'url': _chapUrl};
        Navigator.pop(context, result);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: style.bgColor,
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  /// Build body page
  Widget _buildBody() {
    return Column(
      children: <Widget>[
        _buildReaderTop(),
        _buildReaderView()
      ],
    );
  }

  /// Build reader view show text html;
  Widget _buildReaderTop() {
    return Ink(
      padding: EdgeInsets.fromLTRB(16, 28, 16, 4),
      color: style.topColor,
      child: Center(child: Text(
        _chapName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: style.textColor),
      ),),
    );
  }

  /// Build reader view show text html;
  Widget _buildReaderView() {
    if(_loading) {
      return Expanded(child: Center(child: new CircularProgressIndicator()));
    }
    return Expanded(
      child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(style.paddingLR, 24, style.paddingLR, 24),
      controller: scrollController,
      child: Text(
        _chapContent,
        textAlign: TextAlign.justify,
        style: TextStyle(
          color: style.textColor,
          fontFamily: style.fontFamily,
          fontSize: style.textSize,
          height: style.lineHeight,
        ),
      ),
    ),);
  }

  /// Build bottom bar
  Widget _buildBottomBar() {
    return BottomAppBar(
      color: style.bottomColor,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, color: style.textColor,),
            tooltip: 'Chương trước' ,
            onPressed: prevChapter,
          ),
          IconButton(
            icon: Icon(Icons.cached, color: style.textColor),
            tooltip: 'Sửa nội dung' ,
            onPressed: () {
              bool isPause = isSpeaking;
              if(isSpeaking) {
                _stopSpeak();
              }
              Navigator.push(context, new MaterialPageRoute(
                    builder: (context) => new ReplaceTextDialog(isPause: isPause)
              ))
              .then((result) {
                if(result != null && result is Map) {
                  if(result['isModify']) {
                    _applyReplaceText(result['isPause']);
                  }
                }
              });
            },
          ),
          IconButton(
            iconSize: 36,
            icon: Icon(
                isSpeaking ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: style.textColor),
            tooltip: 'Nghe đọc' ,
            onPressed: () {
              if(isSpeaking) {
                _stopSpeak();
              } else {
                _startSpeak();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.palette, color: style.textColor),
            tooltip: 'Định dạng đọc' ,
            onPressed: () {
              if(_showStylePop && bottomSheetController != null) {
                bottomSheetController.close();
              } else {
                _buildStylePopup();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: style.textColor),
            tooltip: 'Chương sau' ,
            onPressed: nextChapter,
          ),
        ],
      ),
    );
  }

  _buildStylePopup() {
    _showStylePop = true;
    bottomSheetController = _scaffoldKey.currentState.showBottomSheet<void>((context) {
      Widget content = Container(
          color: style.bgPopColor,
          height: 350,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  buildStyleTextSize(),
                  buildStyleFontFamily(),
                  buildStyleBgColor(),
                  buildStyleLineHeight(),
                  buildStylePaddingLR(),
                  buildSpeechSpeedView(),
                  buildSpeechPitchView(),
                ],)
          )
      );
      return Theme(
          data: style.brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light(),
          child: content);
    });
    bottomSheetController.closed.then((void v) => _showStylePop = false);
  }

  Widget buildStyleTextSize() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[Text('Cỡ chữ:', style: TextStyle(color: style.textColor),),],
        ),),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove, color: style.textColor,),
              iconSize: 18.0,
              padding: EdgeInsets.all(0),
              onPressed: textSizeDown,
              highlightColor: Colors.lightBlue,
            ),
            Text(style.textSize.toString(), style: TextStyle(color: style.textColor),),
            IconButton(
              icon: Icon(Icons.add, color: style.textColor,),
              iconSize: 18.0,
              padding: EdgeInsets.all(0),
              onPressed: textSizeUp,
              highlightColor: Colors.lightBlue,
            )
          ],
        ),
      ],);
  }

  Widget buildStyleFontFamily() {
    return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Expanded(child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text('Font chữ:',
            style: TextStyle(color: style.textColor)
        ),],
      )),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          DropdownButton(
            value: style.fontFamily,
            items: fontItems,
            onChanged: changeFont,
            style: TextStyle(color: style.textColor, decorationColor: style.textColor),
          )
        ],
      ),
    ],);
  }

  Widget buildStyleBgColor() {
    return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Expanded(child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text('Màu nền:', style: TextStyle(color: style.textColor)),],
      )),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          DropdownButton(
              value: style.bgColor,
              items: bgColorsItems,
              style: TextStyle(color: style.textColor, decorationColor: style.textColor),
              onChanged: changeBgColor)
        ],
      ),
    ],);
  }

  Widget buildStyleLineHeight() {
    return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Expanded(child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text('Cao dòng:', style: TextStyle(color: style.textColor)),],
      )),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          DropdownButton(
              value: style.lineHeight,
              items: lineHeightItems,
              style: TextStyle(color: style.textColor, decorationColor: style.textColor),
              onChanged: changeLineHeight)
        ],
      ),
    ],);
  }

  Widget buildStylePaddingLR() {
    return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Expanded(child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text('Cách lề:', style: TextStyle(color: style.textColor)),],
      )),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          DropdownButton(
              value: style.paddingLR,
              items: paddingItems,
              style: TextStyle(color: style.textColor, decorationColor: style.textColor),
              onChanged: changePaddingLR)
        ],
      ),
    ],);
  }

  Widget buildSpeechSpeedView() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text('Tốc độ đọc', style: TextStyle(color: style.textColor),),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove, color: style.textColor,),
              iconSize: 18.0,
              padding: EdgeInsets.all(0),
              onPressed: speechSpeedDown,
            ),
            Text(speechRate.toString(), style: TextStyle(color: style.textColor),),
            IconButton(
              icon: Icon(Icons.add, color: style.textColor,),
              iconSize: 18.0,
              padding: EdgeInsets.all(0),
              onPressed: speechSpeedUp,)
          ],
        ),
      ],);
  }

  Widget buildSpeechPitchView() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text('Giọng đọc', style: TextStyle(color: style.textColor),),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove, color: style.textColor,),
              iconSize: 18.0,
              padding: EdgeInsets.all(0),
              onPressed: speechPitchDown,
              highlightColor: Colors.lightBlue,
            ),
            Text(pitch.toString(), style: TextStyle(color: style.textColor),),
            IconButton(
              icon: Icon(Icons.add, color: style.textColor,),
              iconSize: 18.0,
              padding: EdgeInsets.all(0),
              onPressed: speechPitchUp,
              highlightColor: Colors.lightBlue,
            )
          ],
        ),
      ],);
  }

  void prevChapter() {
    Log.d(TAG, '_prevChapter url = $_prevChapUrl');
    if(!_loading && HtmlUtil.isUrl(_prevChapUrl)) {
      _chapUrl = _prevChapUrl;
      loadChapterContent();
      scrollController.jumpTo(0);
      currentSpeak = 0;
    }
  }

  void nextChapter() {
    Log.d(TAG, '_nextChapter url = $_nextChapUrl');
    if(!_loading && HtmlUtil.isUrl(_nextChapUrl)) {
      _chapUrl = _nextChapUrl;
      loadChapterContent();
      scrollController.jumpTo(0);
      currentSpeak = 0;
    }
  }

  void textSizeUp() {
    if(style.textSize > 40) return;
    setState(() {
      style.textSize += 2;
    });
    preferencesData.saveReaderProperty(PREFS_STYLE_SIZE, style.textSize);
  }

  void textSizeDown() {
    if(style.textSize <= 6) return;
    setState(() {
      style.textSize -= 2;
    });
    preferencesData.saveReaderProperty(PREFS_STYLE_SIZE, style.textSize);
  }

  void changeFont(String font) {
    setState(() {
      style.fontFamily = font;
    });
    bottomSheetController.setState(() {
      style.fontFamily = font;
    });
    preferencesData.saveReaderProperty(PREFS_STYLE_FONT, font);
  }

  void changeBgColor(Color color) {
    setState(() {
      if(color == bgColors['dark']) {
        style.changeColor('dark');
      } else if(color == bgColors['light']) {
        style.changeColor('light');
      } else if(color == bgColors['yellow']) {
        style.changeColor('yellow');
      }
    });
    bottomSheetController.setState(() {
      if(color == bgColors['dark']) {
        style.changeColor('dark');
        preferencesData.saveReaderProperty(PREFS_STYLE_THEME, 'dark');
      } else if(color == bgColors['light']) {
        style.changeColor('light');
        preferencesData.saveReaderProperty(PREFS_STYLE_THEME, 'light');
      } else if(color == bgColors['yellow']) {
        style.changeColor('yellow');
        preferencesData.saveReaderProperty(PREFS_STYLE_THEME, 'yellow');
      }
    });
  }

  void changeLineHeight(double value) {
    setState(() {
      style.lineHeight = value;
    });
    bottomSheetController.setState(() {
      style.lineHeight = value;
    });
    preferencesData.saveReaderProperty(PREFS_STYLE_HEIGHT, value);
  }

  void changePaddingLR(double value) {
    setState(() {
      style.paddingLR = value;
    });
    bottomSheetController.setState(() {
      style.paddingLR = value;
    });
    preferencesData.saveReaderProperty(PREFS_STYLE_PADDING, value);
  }

  void speechPitchUp() async {
    if(pitch == 1) return;
    bottomSheetController.setState(() {
      pitch = _rounDouble(pitch + 0.05, 2);
    });
    changeSpeechPitch();
  }


  void speechPitchDown() async {
    if(pitch == 0.1) return;
    bottomSheetController.setState(() {
      pitch = _rounDouble(pitch - 0.05, 2);
    });
    changeSpeechPitch();
  }

  void changeSpeechPitch() async {
    bool speaking = isSpeaking;
    if(isSpeaking) await _stopSpeak();
    await flutterTts.setPitch(pitch);
    if(speaking) await _startSpeak();
    preferencesData.saveReaderProperty(PREFS_SPEECH_PITCH, pitch);
  }

  void speechSpeedUp() async {
    if(speechRate == 1) return;
    bottomSheetController.setState(() {
      speechRate = _rounDouble(speechRate + 0.05, 2);
    });
    changeSpeechSpeed();
  }


  void speechSpeedDown() async {
    if(speechRate == 0.1) return;
    bottomSheetController.setState(() {
      speechRate = _rounDouble(speechRate - 0.05, 2);
    });
    changeSpeechSpeed();
  }

  void changeSpeechSpeed() async {
    bool speaking = isSpeaking;
    if(isSpeaking) await _stopSpeak();
    await flutterTts.setSpeechRate(speechRate);
    if(speaking) await _startSpeak();
    preferencesData.saveReaderProperty(PREFS_SPEECH_SPEED, speechRate);
  }

  // Khoi tao text to speech;
  initTextToSpeech() {
    flutterTts = FlutterTts();

    _setSpeakProperty();

    flutterTts.setStartHandler((i) {
      Log.d(TAG, 'flutterTts.setStartHandler: $i');
      setState(() {
        isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler((i) {
      Log.d(TAG, 'flutterTts.setCompletionHandler: $i');
      currentSpeak = i;
      if(currentSpeak == speechList.length - 1) {
        nextChapter();
      }
    });

    flutterTts.setErrorHandler((msg) {
      Log.d(TAG, 'flutterTts.setErrorHandler: $msg');
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future _setSpeakProperty() async {
    await flutterTts.setLanguage('vi-VN');

    await flutterTts.setSpeechRate(speechRate);

    await flutterTts.setPitch(pitch);
  }

  /// Doc text
  Future _startSpeak() async {
    if(speechList == null || speechList.length == 0 || currentSpeak >= speechList.length) return;
    var result = await flutterTts.speak(speechList[currentSpeak], currentSpeak.toString());
    if (result == 1) setState(() => isSpeaking = true);
    int i = currentSpeak + 1;
    while (i < speechList.length) {
      await flutterTts.speakAdd(speechList[i], i.toString());
      i++;
    }
  }

  /// DUng doc text
  Future _stopSpeak() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => isSpeaking = false);
    preferencesData.saveReadingSpeechPos(widget.bookUrl, currentSpeak);
  }

  _applyReplaceText(bool isPause) async {
    var listRpt = await preferencesData.getListReplace();
    if(listRpt != null) {
      String content = _chapContent;
      for(var rpt in listRpt) {
        content = content.replaceAll(rpt.oldText, rpt.newText);
      }
      setState(() {
        _chapContent = content;
        speechList = _chapContent.split('\n');
      });
    }

    if(isPause) _startSpeak();
  }

  double _rounDouble(double val, double places){
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }
}


