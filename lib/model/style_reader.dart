
import 'dart:ui';

import 'package:bookreader/data/const.dart';

class StyleReader {
  Color bgColor;
  Color topColor;
  Color bottomColor;
  Color textColor;
  double textSize = 20;
  double lineHeight = 1.2;
  double paddingLR = 16;
  String fontFamily = fontItems[0].value;

  StyleReader() {
    changeColor('dark');
  }

  void changeColor(String themeColor) {
    bgColor = bgColors[themeColor];
    topColor = topColors[themeColor];
    bottomColor = bottomColors[themeColor];
    textColor  = txtColors[themeColor];
  }
}