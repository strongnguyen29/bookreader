import 'package:bookreader/data/const.dart';
import 'package:bookreader/data/preferences_data.dart';
import 'package:bookreader/data/reponsitory.dart';
import 'package:bookreader/model/chapter.dart';
import 'package:bookreader/reader.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:bookreader/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



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

  DataRepon dataRepon;
  PreferencesData preferencesData;
  Future<List<Chapter>> future;

  var scrollController = new ScrollController();

  List<Chapter> listChapter = [];
  List<int> listPage = [];

  Chapter readingChapter;

  String bookUrl;
  String bookName;
  bool loading = false;
  int page = 1;
  int totalPage = 0;

  @override
  void initState() {
    super.initState();
    bookUrl = this.widget.url;

    dataRepon = new DataRepon();
    preferencesData = new PreferencesData();
    preferencesData.getReadingChapter(bookUrl).then((chap) {
      if(chap == null) return;

      setState(() {
        readingChapter = chap;
      });
    });
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
    loading = true;

    // get current page is saved;
    page = await preferencesData.getCurrentPage(bookUrl);
    // start load list chaps
    future = dataRepon.getListChapter(bookUrl, page);
    future.then((result) {
      setState(() {
        loading = false;
        listChapter = result;
        totalPage = dataRepon.totalPage;
        bookName = dataRepon.bookName;
        // add dropdown item page
        if(listPage.length == 0) {
          for(int p = 1; p <= totalPage; p++) {
            listPage.add(p);
          }
        }

        Log.d(TAG, '_listPage.length = ' + listPage.length.toString());
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
          onPressed: _prevPageChapter,
        ),
        FlatButton(
          child: Text('Trang $page'),
          color: Colors.transparent,
          onPressed: () {
            if(listPage.length > 0) {
              _showDialogPages().then((result) {
                _gotoPage(result);
              });
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          color: Colors.white,
          tooltip: 'Next',
          onPressed: _nextPageChapter,
        )
      ],
    );
  }

  /// Build title appbar
  Widget _buildAppbarTitle() {
    if(bookName == null) {
      return Text('DS Chương', style: TextStyle(color: Colors.white),);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('DS Chương', style: TextStyle(color: Colors.white),),
        Text(
          bookName,
          style: TextStyle(color: Colors.white70, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis
        )
      ],
    );
  }

  /// Build Body page;
  Widget _buildBody() {
    if(readingChapter == null) {
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
        title: Text(readingChapter.name, maxLines: 2, overflow: TextOverflow.ellipsis,),
        onTap: () {
          // Action item click
          startReadingChapter(readingChapter.name, readingChapter.url, true);
        }
      ),
    );
  }

  /// Build list view
  Widget _buildListView() {
    if(loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
          itemCount: listChapter.length,
          controller: scrollController,
          itemBuilder: (BuildContext context, int i) {
            return _buildListRow(listChapter[i].name, listChapter[i].url);
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
            preferencesData.saveReadingChapter(bookUrl, name, uri.toString());
            startReadingChapter(name, url, false);
          } catch (e) {
            Log.e(TAG, url);
            Log.e(TAG, e.toString());
            ToastUtil.error('Chương lỗi URL');
          }
        }
    );
  }

  Future<int> _showDialogPages() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn trang'),
          content: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: listPage.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: Card(
                    color: listPage[index] == page ? Colors.lightBlue : Colors.white24,
                    child: Center(child: Text(listPage[index].toString()),),),
                  onTap: () {
                    if(listPage[index] != page) {
                      Navigator.pop(context, listPage[index]);
                    }
                  },
                );
              },
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context, page);
              },
              child: Text('Hủy'))
          ],
        );
      }
    );
  }

  /// Previous page chapter
  void _nextPageChapter() {
    if(totalPage > 0 && page + 1 > totalPage) {
      ToastUtil.normal('Trang cuối');
      return;
    }
    _gotoPage(page + 1);
  }

  /// Next page chapter
  void _prevPageChapter() {
    if(page == 1) {
      ToastUtil.normal('Trang đầu');
      return;
    }
    _gotoPage(page - 1);
  }

  /// Data is load when page change
  void _gotoPage(int p) {
    if(p == null || p < 1 || page == p) return;

    setState(() {
      page = p;
    });
    loading = true;
    future = dataRepon.getListChapter(bookUrl, page);
    future.then((result) {
      setState(() {
        loading = false;
        listChapter = result;
      });
    });
    scrollController.jumpTo(0);
    preferencesData.saveCurrentPage(bookUrl, page);
  }

  void startReadingChapter(String chapName, String chapUrl, bool isResume) {
    Uri uri = Uri.parse(chapUrl);
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => new ReaderPage(
            bookUrl: bookUrl,
            bookName: bookName,
            chapName: chapName,
            chapUrl: uri.toString(),
            isResume: isResume,
        )
      ),
    ).then((result) {
      if(result != null && result is Map) {
        setState(() {
          readingChapter = new Chapter(result['name'], result['url']);
        });
      }
    });
  }
}


















