
import 'dart:ui';

import 'package:flutter/material.dart';


const Map<String, Color> bgColors = {
  'yellow' : const Color.fromRGBO(231, 222, 199, 1),
  'dark' : const Color.fromRGBO(48, 48, 48, 1),
  'light' : const Color.fromRGBO(240, 240, 240, 1)
};

const Map<String, Color> bgPopColors = {
  'yellow' : const Color.fromRGBO(229, 222, 203, 1),
  'dark' : const Color.fromRGBO(45, 45, 45, 1),
  'light' : const Color.fromRGBO(230, 230, 230, 1)
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

const Map<String, Brightness> themes = {
  'yellow' : Brightness.light,
  'dark' : Brightness.dark,
  'light' : Brightness.light,
};

final List<DropdownMenuItem<String>> fontItems = [
  new DropdownMenuItem(child: Text('Arial'), value: 'Arial',),
  new DropdownMenuItem(child: Text('Bookerly'), value: 'Bookerly',),
  new DropdownMenuItem(child: Text('Georgia'), value: 'Georgia',),
  new DropdownMenuItem(child: Text('Literata'), value: 'Literata',),
  new DropdownMenuItem(child: Text('Palatino'), value: 'Palatino',),
  new DropdownMenuItem(child: Text('Time New Roman'), value: 'TimeNewRoman',)
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
