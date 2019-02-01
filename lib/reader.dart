import 'package:bookreader/data/const.dart';
import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/model/style_reader.dart';
import 'package:bookreader/util/html_util.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:bookreader/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ReaderPage extends StatefulWidget {
  final String bookUrl;
  final String bookName;
  final String chapUrl;
  final String chapName;

  const ReaderPage({Key key, this.bookUrl, this.bookName, this.chapUrl, this.chapName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ReaderState();
  }
}


/// Class State of page;
class ReaderState extends State<ReaderPage> {
  static const String TAG = 'ReaderState';
  // Scroll controller text view
  final ScrollController scrollController = new ScrollController();

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController<void> bottomSheetController;
  DataRepon _dataRepon;

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
  double speechRate;
  double pitch;
  bool isSpeech;
  int speechPos;
  List<String> speechList = [];

  bool _loading = false;
  bool _showStylePop = false;

  @override
  void initState() {
    super.initState();
    Log.d(TAG, 'initState');
    _chapUrl = widget.chapUrl;
    _chapName = widget.chapName ?? 'No name';

    style = StyleReader();
    _dataRepon = DataRepon();

    loadChapterContent();
  }

  @override
  Widget build(BuildContext context) {
    Log.d(TAG, 'build');
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: style.bgColor,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
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
            onPressed: _prevChapter,
          ),
          IconButton(
            icon: Icon(Icons.cached, color: style.textColor),
            tooltip: 'Sửa nội dung' ,
            onPressed: () {},),
          IconButton(
            iconSize: 36,
            icon: Icon(Icons.play_circle_outline, color: style.textColor),
            tooltip: 'Nghe đọc' ,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.palette, color: style.textColor),
            tooltip: 'Định dạng đọc' ,
            onPressed: () {
              if(_showStylePop && bottomSheetController != null) {
                bottomSheetController.close();
                _showStylePop = false;
              } else {
                _buildStylePopup();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: style.textColor),
            tooltip: 'Chương sau' ,
            onPressed: _nextChapter,
          ),
        ],
      ),
    );
  }

  _buildStylePopup() {
    _showStylePop = true;
    bottomSheetController = _scaffoldKey.currentState.showBottomSheet<void>((context) {
          return Container(
              color: style.bgColor,
              height: 300,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildStyleTextSize(),
                      buildStyleFontFamily(),
                      buildStyleBgColor(),
                      buildStyleLineHeight(),
                      buildStylePaddingLR()
                    ],)
              )
          );
        });
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
            Card(color: Colors.white24, child: IconButton(
              icon: Icon(Icons.remove, color: style.textColor,),
              iconSize: 18.0,
              padding: EdgeInsets.all(0),
              onPressed: textSizeDown,
            )),
            Card(color: Colors.white24, child: IconButton(
              icon: Icon(Icons.add, color: style.textColor,),
              iconSize: 18.0,
              padding: EdgeInsets.all(0),
              onPressed: textSizeUp,))
          ],
        ),
      ],);
  }

  Widget buildStyleFontFamily() {
    return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Expanded(child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[Text('Font chữ:', style: TextStyle(color: style.textColor)),],
      )),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          DropdownButton(value: style.fontFamily, items: fontItems, onChanged: changeFont)
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
          DropdownButton(value: style.bgColor, items: bgColorsItems, onChanged: changeBgColor)
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
          DropdownButton(value: style.lineHeight, items: lineHeightItems, onChanged: changeLineHeight)
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
          DropdownButton(value: style.paddingLR, items: paddingItems, onChanged: changePaddingLR)
        ],
      ),
    ],);
  }

  void _prevChapter() {
    Log.d(TAG, '_prevChapter url = $_prevChapUrl');
    if(!_loading && HtmlUtil.isUrl(_prevChapUrl)) {
      _chapUrl = _prevChapUrl;
      loadChapterContent();
      scrollController.jumpTo(0);
    }
  }

  void _nextChapter() {
    Log.d(TAG, '_nextChapter url = $_nextChapUrl');
    if(!_loading && HtmlUtil.isUrl(_nextChapUrl)) {
      _chapUrl = _nextChapUrl;
      loadChapterContent();
      scrollController.jumpTo(0);
    }
  }

  /// Load chapter content;
  loadChapterContent() async {
    _loading = true;
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
    });
  }

  void textSizeUp() {
    if(style.textSize > 40) return;
    setState(() {
      style.textSize += 2;
    });
  }

  void textSizeDown() {
    if(style.textSize <= 6) return;
    setState(() {
      style.textSize -= 2;
    });
  }

  void changeFont(String font) {
    setState(() {
      style.fontFamily = font;
    });
  }

  void changeTextColor(Color color) {
    setState(() {
      style.textColor = color;
    });
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
  }

  void changeLineHeight(double value) {
    setState(() {
      style.lineHeight = value;
    });
  }

  void changePaddingLR(double value) {
    style.paddingLR = value;
  }

}

