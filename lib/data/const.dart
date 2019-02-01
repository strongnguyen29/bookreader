
import 'dart:ui';

import 'package:flutter/material.dart';

const Map<String, Color> bgColors = {
  'yellow' : const Color.fromRGBO(231, 222, 199, 1),
  'dark' : const Color.fromRGBO(48, 48, 48, 1),
  'light' : const Color.fromRGBO(240, 240, 240, 1)
};

const Map<String, Color> txtColors = {
  'yellow' : const Color.fromRGBO(93, 66, 50, 1),
  'dark' : const Color.fromRGBO(255, 255, 255, 0.9),
  'light' : const Color.fromRGBO(0, 0, 0, 0.87),
};

const Map<String, Color> topColors = {
  'yellow' : const Color.fromRGBO(0, 0, 0, 0.12),
  'dark' : const Color(0x1FFFFFFF),
  'light' : const Color.fromRGBO(0, 0, 0, 0.12),
};

const Map<String, Color> bottomColors = {
  'yellow' : const Color.fromRGBO(255, 255, 255, 0.12),
  'dark' : const Color(0x1FFFFFFF),
  'light' : const Color.fromRGBO(0, 0, 0, 0.12),
};

final List<DropdownMenuItem<String>> fontItems = [
  new DropdownMenuItem(child: Text('Tahoma'), value: 'tahoma',),
  new DropdownMenuItem(child: Text('Arial'), value: 'arial',),
  new DropdownMenuItem(child: Text('Cafeta'), value: 'cafeta',),
  new DropdownMenuItem(child: Text('Time new roman'), value: 'time new roman',)
];

final List<DropdownMenuItem<Color>> bgColorsItems = [
  new DropdownMenuItem(child: Text('Màu tối'), value: bgColors['dark'],),
  new DropdownMenuItem(child: Text('Màu sáng'), value: bgColors['light'],),
  new DropdownMenuItem(child: Text('Màu vàng'), value: bgColors['yellow'],)
];

final List<DropdownMenuItem<double>> lineHeightItems = [
  new DropdownMenuItem(child: Text('x1 cỡ chữ'), value: 1,),
  new DropdownMenuItem(child: Text('x1.2 cỡ chữ'), value: 1.2,),
  new DropdownMenuItem(child: Text('x1.5 cỡ chữ'), value: 1.5,)
];

final List<DropdownMenuItem<double>> paddingItems = [
  new DropdownMenuItem(child: Text('16 DP'), value: 16,),
  new DropdownMenuItem(child: Text('24 DP'), value: 24,),
  new DropdownMenuItem(child: Text('32 DP'), value: 32,)
];
