import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/item.dart';
import 'package:flutter_picker/selector.dart';

class FlutterPicker {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/photo_picker');

  static void getPicItems(bool gif) {
    _channel.invokeMethod('openGallery', gif);
  }

  static void toast(String message) {
    _channel.invokeMethod('toast', message);
  }

  static int screenWidth = 0;
  static int screenHeight = 0;
  static double density = 0.0;

  static void openCamera() {
    _channel.invokeMethod('openCamera');
  }

  static Future<int> getScreenHeight() async {
    final int screenHeight = await _channel.invokeMethod('getScreenHeight');
    return screenHeight;
  }

  static Future<int> getScreenWidth() async {
    final int screenWidth = await _channel.invokeMethod('getScreenWidth');
    return screenWidth;
  }

  static Future<double> getDensity() async {
    final double density = await _channel.invokeMethod('getDensity');
    return density;
  }

  static void switchFullScreen(bool fullScreen) {
    _channel.invokeMethod('switchFullScreen', fullScreen);
  }

  static void getItems(String cateLog) {
    _channel.invokeMethod('getItems', cateLog);
  }
}

class PhotoPicker {
  static PhotoPicker _instance;

  static PhotoPicker get instance {
    if (_instance == null) {
      _instance = new PhotoPicker();
    }

    return _instance;
  }

  BuildContext _context;
  int _max = 9;
  List<PicItem> _picItems;
  bool _gif = true;

  PhotoPicker context(BuildContext context) {
    _context = context;
    return this;
  }

  PhotoPicker multi(int max) {
    _max = max;
    return this;
  }

  PhotoPicker single() {
    _max = 1;
    return this;
  }

  PhotoPicker gif(bool gif) {
    _gif = gif;
    return this;
  }

  PhotoPicker selected(List<PicItem> picItems) {
    _picItems = picItems;
    return this;
  }

  void start(ValueChanged<List<PicItem>> onChanged) {
    Navigator.of(_context).push(new MaterialPageRoute(builder: (context) {
      return new SelectorApp(_max, onChanged, _picItems, _gif);
    }));
  }
}
