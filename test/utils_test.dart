
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


}

