import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/model/chapter.dart';
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

/**
 * Class State of page;
 */
class ReaderState extends State<ReaderPage> {
  static final String TAG = 'ReaderState';


  String _chapUrl;
  String _chapName;


  @override
  void initState() {
    super.initState();
    _chapUrl = widget.chapUrl;
    _chapName = widget.chapName;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: _buildBody(),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floatingActionButton: _buildFloatingButton(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Build body page
  Widget _buildBody() {
    return Center(child: Column(children: <Widget>[
      Text(widget.bookName),
      Text(widget.bookUrl),
      Text(_chapName),
      Text(_chapUrl),
    ],));
  }

  /// Build bottom bar
  Widget _buildBottomBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: 'Chương trước' ,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.cached),
            tooltip: 'Sửa nội dung' ,
            onPressed: () {},),
          IconButton(
            iconSize: 36,
            icon: Icon(Icons.play_circle_outline),
            tooltip: 'Nghe đọc' ,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.palette),
            tooltip: 'Định dạng đọc' ,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            tooltip: 'Chương sau' ,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

}