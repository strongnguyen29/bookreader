import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:bookreader/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookInfoPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
        title: 'Danh sách chương',
        theme: new ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.lightBlue,
            accentColor: Colors.lightBlueAccent
        ),
        home: new BookInfo()
    );
  }

}

class BookInfo extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new BookInfoState();
  }
}
/**
 * Class State of page;
 */
class BookInfoState extends State<BookInfo> {
  static final String TAG = 'BookInfoState';

  DataRepon _dataRepon;
  Future<List<Chapter>> _future;

  var _scrollController = new ScrollController();

  List<Chapter> _listChapter = [];
  List<DropdownMenuItem<String>> _listPage = [
    new DropdownMenuItem(
      value: '1',
      child: new Text('Trang 1')
    )
  ];

  Chapter readingChap;

  final String url = 'https://truyencv.com/thien-dao-thu-vien/';
  bool _loading = false;
  int _page = 1;
  int _totalPage = 0;

  @override
  void initState() {
    super.initState();

    _dataRepon = new DataRepon();
    _loadReadingChapter();
    startLoadData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: _buildAppbar(),
      body: _buildListView()
    );
  }

  /// First load data;
  startLoadData() async {
    _loading = true;

    // get current page is saved;
    await _getCurrentPage();
    // start load list chaps
    _future = _dataRepon.getListChapter(url, _page);
    _future.then((result) {
      setState(() {
        _loading = false;
        _listChapter = result;
        _totalPage = _dataRepon.totalPage;
        // add dropdown item page
        if(_listPage.length == 1 && _totalPage > 1) {
          for(int p = 2; p <= _totalPage; p++) {
            _listPage.add(
                new DropdownMenuItem(
                    value: p.toString(),
                    child: new Text('Trang $p')
                )
            );
          }
        }
      });
    });
  }

  /// Buil App bar
  Widget _buildAppbar() {
    return AppBar(
      title: Text('DS chương', style: TextStyle(color: Colors.white),),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          tooltip: 'Prev',
          onPressed: _prevChapter,
        ),
        DropdownButton(
            value: _totalPage == 0 ? null : _page.toString(),
            items: _listPage,
            onChanged: _onChangePage
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          color: Colors.white,
          tooltip: 'Next',
          onPressed: _nextChapter,
        )
      ],
    );
  }

  /// Build list view
  Widget _buildListView() {
    if(_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
          itemCount: _listChapter.length,
          controller: _scrollController,
          itemBuilder: (BuildContext context, int i) {
            return _buildListRow(_listChapter[i].name, _listChapter[i].url);
          }
      );
    }
  }

  /// Build row listView
  Widget _buildListRow(String name, String url) {
    return ListTile(
      title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis
      ),
      subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        // Action item click
        ToastUtil.done(name);
      }
    );
  }

  /// Previous page chapter
  void _nextChapter() {
    if(_totalPage > 0 && _page + 1 > _totalPage) return;
    _gotoPage(_page++);
  }

  /// Next page chapter
  void _prevChapter() {
    if(_page == 1) return;
    _gotoPage(_page--);
  }

  /// function process action when ButtonDropdown change item;
  void _onChangePage(String p) {
    _gotoPage(int.parse(p));
  }

  /// Data is load when page change
  void _gotoPage(int p) {
    setState(() {
      _page = p;
    });
    _loading = true;
    _future = _dataRepon.getListChapter(url, _page);
    _future.then((result) {
      setState(() {
        _loading = false;
        _listChapter = result;
      });
    });
    _scrollController.jumpTo(0);
    _saveCurrentPage();
  }

  /// Get current page
  _getCurrentPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _page = prefs.getInt(url);
    });
  }


  /// Luu trang ds chuong hien tai
  void _saveCurrentPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(url, _page);
    Log.d(TAG, '_saveCurrentPage page = $_page');
  }

  void _loadReadingChapter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(url + '_reading') ?? null;
    if(list != null && list.length >= 2) {
      setState(() {
        readingChap = new Chapter(list[0], list[1]);
      });

      Log.d(TAG, '_loadReadingChapter Done :: ' + list[0]);
    }
  }
}