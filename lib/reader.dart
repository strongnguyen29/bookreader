import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/html_util.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:bookreader/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';

const Map<String, Color> colorsReader = {
  'vang' : Color.fromRGBO(231, 222, 199, 1),
  'toi' : Color.fromRGBO(48, 48, 48, 1),
  'sang' : Color.fromRGBO(240, 240, 240, 1),
  'vang_txt' : Color.fromRGBO(93, 66, 50, 1),
  'toi_txt' : Color.fromRGBO(255, 255, 255, 0.9),
  'sang_txt' : Color.fromRGBO(0, 0, 0, 0.87),
};

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

  // Scroll controller text view
  ScrollController _controller = new ScrollController();

  bool loading = false;

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

  loadChapterContent() async {
    loading = true;
    _dataRepon.getChapterContent(_chapUrl).then((result) {

      if(result == null) {
        setState(() => loading == false);
        return;
      }

      setState(() {
        loading = false;
        _chapName = result.name;
        _chapUrl = result.url;
        _chapContent = result.getContent();
        _nextChapUrl = result.nextUrl;
        _prevChapUrl = result.prevUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Log.d(TAG, 'build');
    // TODO: implement build
    return Scaffold(
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
    if(loading) {
      return new Center(child: new CircularProgressIndicator(),);
    }
    return Expanded(
      child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(style.paddingLR, 24, style.paddingLR, 24),
      controller: _controller,
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
            onPressed: () {},
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
              select++;
              if(select == 3) select = 0;
              setState(() {
                style._changeColor(select);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: style.textColor),
            tooltip: 'Chương sau' ,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Future<Map> _buildStyleDialog() async {

  }

}

class StyleReader {
  Color bgColor;
  Color topColor;
  Color bottomColor;
  Color textColor;
  double textSize = 20;
  double lineHeight = 1.2;
  double paddingLR = 16;
  String fontFamily;

  StyleReader() {
    _changeColor(0);
  }

  void _changeColor(int i) {
    switch(i) {
      case 0:
        bgColor = colorsReader['toi'];
        topColor = Colors.white12;
        bottomColor = Colors.white12;
        textColor  = colorsReader['toi_txt'];
        break;
      case 1:
        bgColor = colorsReader['sang'];
        topColor = Colors.black12;
        bottomColor = Colors.black12;
        textColor  = colorsReader['sang_txt'];
        break;
      case 2:
        bgColor = colorsReader['vang'];
        topColor = Colors.black12;
        bottomColor = Colors.white12;
        textColor  = colorsReader['vang_txt'];
        break;
    }
  }
}