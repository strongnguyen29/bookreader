
import 'package:html/dom.dart' as dom;



class HtmlUtil {

  /// Function convert html to String;
  static String htmlToString(String html) {
    String data = '';
    if(html == null || html.isEmpty) return '';
    // parser to html;
    var doc = dom.DocumentFragment.html(html);
    _removeNode(doc);
    doc.nodes.forEach((dom.Node node) {
      if(node is dom.Element) {
        data += node.text;
        if(node.localName == 'br' || node.localName == 'p' || node.localName == 'div') {
          data += '\n';
        }
      } else {
        data += node.text;
      }
    });

    return data;
  }

  /// Function remove Node;
  static dom.Node _removeNode(dom.Node node) {
    if(!node.hasChildNodes()) {
      return node;
    }
    var toRemove = [];
    node.nodes.forEach((dom.Node node1) {
      if(node1 is dom.Element) {
        if(node1.localName == 'iframe'
            || node1.localName == 'script'
            || node1.localName == 'a'
            || node1.localName == 'style') {
          toRemove.add(node1);
        } else {
          _removeNode(node1);
        }
      }
    });
    node.nodes.removeWhere((dom.Node node) => toRemove.contains(node));
    return node;
  }

}