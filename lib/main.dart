
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bookreader/input_url.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(new InputUrlPage());
}

