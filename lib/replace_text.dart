import 'dart:async';
import 'dart:convert';
import 'package:bookreader/data/const.dart';
import 'package:bookreader/data/preferences_data.dart';
import 'package:bookreader/model/replace_text.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum DismissDialogAction {
  cancel,
  save,
}

class ReplaceTextDialog extends StatefulWidget {
  final bool isPause;

  const ReplaceTextDialog({Key key, this.isPause}) : super(key: key);
  @override
  ReplaceTextState createState() => ReplaceTextState();
}

class ReplaceTextState extends State<ReplaceTextDialog> {
  PreferencesData preferencesData;

  TextEditingController inputControllerOld;
  TextEditingController inputControllerNew;

  List<ReplaceText> listReplace = [];


  @override
  void initState() {
    super.initState();

    preferencesData = new PreferencesData();

    inputControllerOld = new TextEditingController();
    inputControllerNew = new TextEditingController();

    preferencesData.getListReplace().then((result) {
      if(result == null) return;

      setState(() {
        listReplace = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
          children: <Widget>[
            buildTextField1(),
            buildTextField2(),
            buildButton(),
            buildDivider(),
            buildListView()
          ],
      ),
    );
  }

  /// Build App bar
  Widget buildAppBar() {
    return AppBar(
        title: Text('Thay thế text', style: TextStyle(color: Colors.white),),
    );
  }

  ///Build text input url
  Widget buildTextField1() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: inputControllerOld,
            decoration: InputDecoration(hintText: 'Nhập text cũ'),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
          )
      ),
    );
  }

  ///Build text input url
  Widget buildTextField2() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: inputControllerNew,
            decoration: InputDecoration(hintText: 'Nhập text mới'),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
          )
      ),
    );
  }

  /// Build button submit input
  Widget buildButton() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            RaisedButton(
              child: Text("Thêm vào list"),
              color: Colors.blue,
              onPressed: _addTextToList,
            )
        )
    );
  }

  /// Build line;
  Widget buildDivider() {
    return Center(child: Padding(
      padding: const EdgeInsets.fromLTRB(48,16,48,16),
      child: Divider(height: 2, color: Colors.lightBlueAccent,),
    ),);
  }

  /// Build ListView urls;
  Widget buildListView() {
    if(listReplace == null || listReplace.length == 0) {
      return Center(child: Text('Chưa có dữ liệu'),);
    }

    return Expanded(child: ListView.builder(
        itemCount: listReplace.length > 0 ? listReplace.length *2 - 1 : 0,
        itemBuilder: (BuildContext context, int i) {
          if(i.isOdd) {
            return new Divider();
          }
          return _buildRow(i~/2);
        }
    ),);
  }

  /// Build row listView
  Widget _buildRow(int pos) {
    return ListTile(
      title: Text(
          listReplace[pos].newText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis
      ),
      subtitle: Text(
          listReplace[pos].oldText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis
      ),
      onTap: () {

      },
      trailing: IconButton(icon: Icon(Icons.close, color: Colors.white30,), onPressed: ()=>_removeRow(pos)),
    );
  }

  /// Them text thay doi vao list;
  _addTextToList() {
    String oldText = inputControllerOld.text;
    String newText = inputControllerNew.text;
    if(oldText == null || oldText.length < 1 || newText == null || newText.length < 1 ) {
      return;
    }
    
    setState(() {
      listReplace.insert(0, new ReplaceText(oldText, newText));
    });

    preferencesData.saveListReplace(listReplace);
  }

  _removeRow(int pos) {
    setState(() {
      listReplace.removeAt(pos);
    });

    preferencesData.saveListReplace(listReplace);
  }
}