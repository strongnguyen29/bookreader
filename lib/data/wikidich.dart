import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class WikiDich {

  var document;
  String url = 'https://wikidich.com/truyen/quy-de-cuong-the-an-choi-trac-tang-dai-t-WQvPOe8h7C3~MnRg';

  WikiDich() {
    document = parse(url);
    print(document.outerHtml);
  }
}