import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/reader.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:bookreader/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


const PREFS_READING_CHAPTER = '_reading_chapter';
const PREFS_CURRENT_PAGE = '_current_page';


class BookInfoPage extends StatefulWidget {
  final String url;

  const BookInfoPage({Key key, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new BookInfoState();
  }
}
/**
 * Class State of page;
 */
class BookInfoState extends State<BookInfoPage> {
  static final String TAG = 'BookInfoState';

  DataRepon _dataRepon;
  Future<List<Chapter>> _future;

  var _scrollController = new ScrollController();

  List<Chapter> _listChapter = [];
  List<int> _listPage = [];

  Chapter _readingChapter;

  String _bookUrl;
  String _bookName;
  bool _loading = false;
  int _page = 1;
  int _totalPage = 0;

  @override
  void initState() {
    super.initState();
    _bookUrl = this.widget.url;

    _dataRepon = new DataRepon();
    _getReadingChapter();
    startLoadData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody()
    );
  }

  /// First load data;
  startLoadData() async {
    _loading = true;

    // get current page is saved;
    await _getCurrentPage();
    // start load list chaps
    _future = _dataRepon.getListChapter(_bookUrl, _page);
    _future.then((result) {
      setState(() {
        _loading = false;
        _listChapter = result;
        _totalPage = _dataRepon.totalPage;
        _bookName = _dataRepon.bookName;
        // add dropdown item page
        if(_listPage.length == 0) {
          for(int p = 1; p <= _totalPage; p++) {
            _listPage.add(p);
          }
        }

        Log.d(TAG, '_listPage.length = ' + _listPage.length.toString());
      });
    });
  }

  /// Build App bar
  Widget _buildAppbar() {
    return AppBar(
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context)
      ),
      title: _buildAppbarTitle(),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          tooltip: 'Prev',
          onPressed: _prevChapter,
        ),
        FlatButton(
          child: Text('Trang $_page'),
          color: Colors.transparent,
          onPressed: () {
            if(_listPage.length > 0) {
              showDialogPages().then((result) {
                _gotoPage(result);
              });
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          color: Colors.white,
          tooltip: 'Next',
          onPressed: _nextChapter,
        )
      ],
    );
  }

  /// Build title appbar
  Widget _buildAppbarTitle() {
    if(_bookName == null) {
      return Text('DS Chương', style: TextStyle(color: Colors.white),);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('DS Chương', style: TextStyle(color: Colors.white),),
        Text(
          _bookName,
          style: TextStyle(color: Colors.white70, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis
        )
      ],
    );
  }

  /// Build Body page;
  Widget _buildBody() {
    if(_readingChapter == null) {
      return _buildListView();
    }

    return Column(
      children: <Widget>[
        _buildButtonReading(),
        Expanded(child: _buildListView(),)
      ],
    );
  }

  /// Build button reading continous
  Widget _buildButtonReading() {
    return Ink(
      color: Colors.white12,
      child: ListTile(
        trailing: const Icon(Icons.bookmark_border),
        title: Text(_readingChapter.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
        onTap: () {
          // Action item click
        }
      ),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis
        ),
        onTap: () {
          try {
            // Action item click
            Uri uri = Uri.parse(url);
            _saveReadingChapter(new Chapter(name, uri.toString()));
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new ReaderPage(
                    bookUrl: _bookUrl,
                    bookName: _bookName,
                    chapName: name,
                    chapUrl: uri.toString(),
                  )
              ),
            );
          } catch (e) {
            Log.e(TAG, url);
            Log.e(TAG, e.toString());
            ToastUtil.error('Chương lỗi URL');
          }
        }
    );
  }

  Future<int> showDialogPages() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn trang'),
          content: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: _listPage.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: Card(
                    color: _listPage[index] == _page ? Colors.lightBlue : Colors.white24,
                    child: Center(child: Text(_listPage[index].toString()),),),
                  onTap: () {
                    if(_listPage[index] != _page) {
                      Navigator.pop(context, _listPage[index]);
                    }
                  },
                );
              },
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context, _page);
              },
              child: Text('Hủy'))
          ],
        );
      }
    );
  }

  /// Previous page chapter
  void _nextChapter() {
    if(_totalPage > 0 && _page + 1 > _totalPage) {
      ToastUtil.normal('Trang cuối');
      return;
    }
    _gotoPage(_page + 1);
  }

  /// Next page chapter
  void _prevChapter() {
    if(_page == 1) {
      ToastUtil.normal('Trang đầu');
      return;
    }
    _gotoPage(_page - 1);
  }

  /// Data is load when page change
  void _gotoPage(int p) {
    if(p == null || p < 1 || _page == p) return;

    setState(() {
      _page = p;
    });
    _loading = true;
    _future = _dataRepon.getListChapter(_bookUrl, _page);
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
      _page = prefs.getInt(_bookUrl + PREFS_CURRENT_PAGE) ?? 1;
    });
  }

  /// Luu trang ds chuong hien tai
  void _saveCurrentPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_bookUrl + PREFS_CURRENT_PAGE, _page);
    Log.d(TAG, '_saveCurrentPage page = $_page');
  }

  /// Get chapter reading info
  void _getReadingChapter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_bookUrl + PREFS_READING_CHAPTER) ?? null;
    if(list != null && list.length >= 2) {
      setState(() {
        _readingChapter = new Chapter(list[0], list[1]);
      });

      Log.d(TAG, '_loadReadingChapter Done :: ' + list[0]);
    }
  }

  /// Luu trang ds chuong hien tai
  void _saveReadingChapter(Chapter chapter) async {
    if(chapter == null) return;

    List<String> list = [chapter.name, chapter.url];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_bookUrl + PREFS_READING_CHAPTER, list);
    setState(() {
      _readingChapter = chapter;
    });
    Log.d(TAG, '_saveReadingChapter name = ' + chapter.name);
  }
}


















