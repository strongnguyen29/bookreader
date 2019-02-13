
import 'dart:convert';

import 'package:bookreader/model/replace_text.dart';
import 'package:bookreader/util/html_util.dart';
import 'package:test/test.dart';
import 'package:bookreader/util/log_util.dart';
import 'package:html/dom.dart' as dom;

void main() {
  test('Test Html Utils', () {
    String html = '<div class="name">aaaaaaaaa</div>bbbbbbbbbb<br>ccccccccccc<br/><div>dddddddddddddd</div><p>eeeeeeeeeeeeee</p>';
    html += '<script>ffffffffffffff</script><style>ggggggggggggggg</style>';
    html += '<div>hhhhhhhhhhhhhh<iframe>iiiiiiiiiiiii</iframe>jjjjjjjjjj</div>';
    Log.d('html', html);
    Log.d('html', HtmlUtil.htmlToString(html));

  });

  test('Test JSON Utils', () {
    ReplaceText text = new ReplaceText("aaaaaa", "bbbbbb");
    List<ReplaceText> list = [text, text, text];

    String js = '[';
    for(int i = 0; i < list.length; i++) {
      if(i != 0) js += ',';
      js += jsonEncode(list[i]);
    }
    js += ']';
    print(js + '\n\n');

    List<dynamic> parserJson = json.decode(js);
    List<ReplaceText> list2 = parserJson.map((i)=> ReplaceText.fromJson(i)).toList();
    print(list2.length.toString());
  });

}

