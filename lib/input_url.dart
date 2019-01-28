import 'package:bookreader/book_info.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:bookreader/util/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputUrlPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
        title: 'Link sách',
        theme: new ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.lightBlue,
          accentColor: Colors.lightBlueAccent
        ),
        home: new InputUrl()
    );
  }
}

class InputUrl extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new InputUrlState();
  }

}

class InputUrlState extends State<InputUrl> {
  static final String TAG = 'InputUrlState';
  static final String BOOK_URLS = 'prefs_book_url';

  final inputController = new TextEditingController();

  TextField textField;

  final List<String> listUrl = <String>[];

  final TextStyle fontSize = const TextStyle(fontSize: 16.0);

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    inputController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();

    // Load list url used;
    _loadListUrl();
    //_resetList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: Column(
        children: <Widget>[
          buildTextField(),
          buildButton(),
          buildDivider(),
          buildListView()
        ],
      )
    );
  }

  _loadListUrl() async {
    if(listUrl.length == 0) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> urls = prefs.getStringList(BOOK_URLS);
        if(urls != null && urls.length > 0) {
          setState(() {
            listUrl.addAll(urls);
            print('Load list url DONE');
          });
        }
      } catch(e) {
        print('LOI: ' + e.toString());
      }
    }
  }

  _resetList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(BOOK_URLS);
  }

  _saveListUrl(String url) async {
    try {
      // Check url isset in list
      if(listUrl.contains(url)) return;
      // Save url
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        listUrl.insert(0, url);
        prefs.setStringList(BOOK_URLS, listUrl);
        print('Save list url DONE');
      });
    } catch(e) {
      print('LOI: ' + e.toString());
    }
  }

  /**
   * Build text input url
   */
  Widget buildTextField() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 112, 16, 16),
          child: TextField(
            controller: inputController,
            decoration: InputDecoration(hintText: 'Nhập link truyện...'),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          )
      ),
    );
  }

  /**
   * Build button submit input
   */
  Widget buildButton() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            RaisedButton(
              child: Text("Xác nhận"),
              color: Colors.blue,
              onPressed: () => _submitInputUrl(context, inputController.text),
            )
        )
    );
  }

  /**
   * Build line;
   */
  Widget buildDivider() {
    return Center(child: Padding(
      padding: const EdgeInsets.fromLTRB(96,16,96,16),
      child: Divider(height: 2, color: Colors.lightBlueAccent,),
    ),);
  }

  /**
   * Build ListView urls;
   */
  Widget buildListView() {
    return Expanded(child: ListView.builder(
        itemCount: listUrl.length > 0 ? listUrl.length *2 - 1 : 0,
        itemBuilder: (BuildContext context, int i) {
          if(i.isOdd) {
            return new Divider();
          }
          return _buildRow(i~/2);
        }
    ),);
  }

  /**
   * Build row listView
   */
  Widget _buildRow(int pos) {
    return ListTile(
      title: Text(
        listUrl[pos],
        style: fontSize,
        maxLines: 1,
        overflow: TextOverflow.ellipsis
      ),
      onTap: () {
        inputController.text = listUrl[pos];
      },
      trailing: IconButton(icon: Icon(Icons.close, color: Colors.white30,), onPressed: ()=>_removeRow(pos)),
    );
  }

  /**
   * Ham xac nhận nhập link;
   */
  void _submitInputUrl(BuildContext context, String url) {

    if(url == null || url.trim().length == 0) {
      ToastUtil.error('Chưa nhập link truyện!');
      return;
    }

    try {
      url = url.trim();
      Uri uri = Uri.parse(url);
      _saveListUrl(uri.toString());
      Navigator.push(context,
        new MaterialPageRoute(
            builder: (context) => new BookInfoPage(url: uri.toString(),)
        ),
      );
    } catch(e) {
      ToastUtil.error('Link không hợp lệ!');
    }
  }

  /// Remove item;
  void _removeRow(int pos) async {
    // Save url
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      listUrl.removeAt(pos);
    });
    prefs.setStringList(BOOK_URLS, listUrl);
    prefs.remove(listUrl[pos] + PREFS_READING_CHAPTER);
    prefs.remove(listUrl[pos] + PREFS_CURRENT_PAGE);
    Log.d(TAG, 'Update list done');
  }

}