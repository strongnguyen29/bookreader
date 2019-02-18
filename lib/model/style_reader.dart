
import 'dart:ui';

import 'package:bookreader/data/const.dart';
import 'package:flutter/material.dart';

class StyleReader {
  Color bgColor;
  Color bgPopColor;
  Color topColor;
  Color bottomColor;
  Color textColor;
  double textSize = 20;
  double lineHeight = 1.2;
  double paddingLR = 16;
  String fontFamily = fontItems[1].value;
  Brightness brightness;

  StyleReader() {
    changeColor('dark');
  }

  void changeColor(String themeColor) {
    bgColor = bgColors[themeColor];
    bgPopColor = bgPopColors[themeColor];
    topColor = topColors[themeColor];
    bottomColor = bottomColors[themeColor];
    textColor  = txtColors[themeColor];
    brightness  = themes[themeColor];
  }
}