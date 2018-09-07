import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/category.dart';
import 'package:flutter_picker/constant.dart';
import 'package:flutter_picker/item.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_picker/placeholder_image_view.dart';
import 'package:flutter_picker/preview.dart';

import 'dart:ui' show lerpDouble;

//const String THEME_QQ = "QQ";
//const String THEME_WECHAT = "WECHAT";
//const String THEME_WHITE = "WHITE";

class SelectorApp extends StatefulWidget {
//  String _theme;
//
//  SelectorApp(this._theme) {
//    if (_theme != THEME_QQ && _theme != THEME_WECHAT && _theme != THEME_WHITE) {
//      _theme = THEME_WHITE;
//    }
//  }
  final ValueChanged<List<PicItem>> _onChanged;
  final int _max;
  final List<PicItem> _items;
  final bool _gif;

  SelectorApp(this._max, this._onChanged, this._items, this._gif);

  @override
  State<StatefulWidget> createState() =>
      new _SelectorState(_max, _onChanged, _items, _gif);
}

class _SelectorState extends State<SelectorApp> with TickerProviderStateMixin {
//  String _theme;
  List<PicItem> _picItems;
  List<CatelogItem> _cateLog;

  final _selectItems = new List<PicItem>();
  int _max;
  bool _isSingle;
  int _rvalue = 0;
  final bool _gif;
  final ValueChanged<List<PicItem>> _onChanged;
  int _cateRvalue = 0;
  bool _hide = true;
  String _text = "";
  BuildContext _scaffoldContext;
  bool _isAnimateShowing = false;

  static const BasicMessageChannel _basicMessageChannel =
      const BasicMessageChannel("flutter_picker/picker_items", StringCodec());

  static const BasicMessageChannel _keysChannel =
      const BasicMessageChannel("flutter_picker/picker_keys", StringCodec());

  static const BasicMessageChannel _itemsChannel = const BasicMessageChannel(
      "flutter_picker/picker_cate_items", StringCodec());

  void select(value) {
    setState(() {
      _rvalue = value;
    });
  }

  double _imageSize;
  double _cateHeight;
  double _height = 0.0;

  _SelectorState(this._max, this._onChanged, List<PicItem> items, this._gif) {
    _isSingle = _max == 1;
    if (null != items) {
      _selectItems.addAll(items);
    }
  }

  void _hideCate() {

    _isAnimateShowing = true;
    isShowAnim = false;

    animation.reverse(from: 1.0);
  }

  bool isShowAnim = true;

  void _open() {
    _isAnimateShowing = true;
    isShowAnim = true;
    setState(() {
      _hide = false;
    });
    animation.forward(from: 0.0);
  }

  AnimationController animation;

  void _listener() {
    setState(() {
      _height = lerpDouble(0.0, _cateHeight, animation.value);
    });
    if (animation.value == 1.0 && isShowAnim) {
      _isAnimateShowing = false;
    } else if (animation.value == 0.0 && !isShowAnim) {
      _isAnimateShowing = false;
      setState(() {
        _hide = true;
      });
    }
  }

  @override
  void dispose() {
    animation.removeListener(_listener);
    animation.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (FlutterPicker.screenWidth == 0) {
      getImageSize();
    } else {
      setState(() {
        double screenWidth = double.parse("${FlutterPicker.screenWidth}");
        _imageSize = (screenWidth - 6.0) / 3.0;
        _cateHeight = double.parse("${FlutterPicker.screenHeight}") - 180.0;
      });
    }
    animation = new AnimationController(
        duration: Duration(milliseconds: 500), vsync: this)
      ..addListener(_listener);

    _basicMessageChannel.setMessageHandler((message) {
      var beanWrapper = new BeanWrapper(message);
      List<PicItem> picItems = beanWrapper.items;

      for (PicItem item in _selectItems) {
        picItems[picItems.indexOf(item)].selected = true;
      }
      if (picItems[0].selected) _selectItems.add(picItems[0]);

      if (!mounted) return;

      setState(() {
        _picItems = picItems;
      });
    });
    _keysChannel.setMessageHandler((message) {
      var cateLog = new CateLog(message);
      if (!mounted) return;

      setState(() {
        _cateLog = cateLog.catelog;
      });
    });
    FlutterPicker.getPicItems(_gif);

    _itemsChannel.setMessageHandler((message) {
      var beanWrapper = new BeanWrapper(message);
      List<PicItem> picItems = beanWrapper.items;

      for (PicItem item in _selectItems) {
        var index = picItems.indexOf(item);
        if (index == -1) continue;
        picItems[index].selected = true;
      }

      if (!mounted) return;

      setState(() {
        _picItems = picItems;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _child;
    if (null != _picItems) {
      List<GridTile> tiles = new List();
      tiles.add(new GridTile(
          child: new GestureDetector(
        onTap: () {
          FlutterPicker.openCamera();
        },
        child: new Container(
          width: _imageSize,
          height: _imageSize,
          color: Color(0xff353535),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Icon(
                Icons.photo_camera,
                color: Color(0xFFA9A9A9),
                size: 45.0,
              ),
              new Container(
                margin: EdgeInsets.only(top: 10.0),
                child: new Text(
                  "拍照",
                  style: new TextStyle(fontSize: 14.0, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      )));
      for (int i = 0; i < _picItems.length; i++) {
        var picItem = _picItems[i];
        //创建gridView 图片item
        tiles.add(new GridTile(
            child: new Stack(
          children: <Widget>[
            new GestureDetector(
              onTap: () {
                _preview(i, _picItems, _rvalue, false);
              },
              child: new PlaceHolderImageView(
                fit: BoxFit.cover,
                width: _imageSize,
                height: _imageSize,
                imageProvider: new FileImage(new File(picItem.uri)),
              ),
            ),
            new Offstage(
              child: new GestureDetector(
                onTap: () {
                  _preview(_selectItems.indexOf(_picItems[i]), _selectItems, 0);
                },
                child: new Container(color: const Color(0x4f000000)),
              ),
              offstage: !picItem.selected,
            ),
            new Positioned(
              child: _isSingle
                  ? new Radio(
                      value: i,
                      groupValue: _rvalue,
                      activeColor: new Color(0xffFF6E40),
                      onChanged: (int val) {
                        _selectItems.clear();
                        _selectItems.add(picItem);
                        select(val);
                      })
                  : new Checkbox(
                      value: picItem.selected,
                      activeColor: new Color(0xffFF6E40),
                      onChanged: (checked) {
                        bool selected;
                        if (checked) {
                          if (_selectItems.length == _max) {
                            _showSnackBar("最多只能选择$_max张图片");
//                            FlutterPicker.toast("最多只能选择$_max张图片");
                            selected = false;
                          } else {
                            _selectItems.add(picItem);
                            selected = true;
                          }
                        } else {
                          _selectItems.remove(picItem);
                          selected = false;
                        }
                        setState(() {
                          picItem.selected = selected;
                        });
                      }),
              top: 0.0,
              right: 0.0,
            ),
          ],
        )));
      }
      _child = new Builder(builder: (context) {
        return new GridView.count(
          crossAxisCount: 3,
          children: tiles,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          padding: const EdgeInsets.all(2.0),
        );
      });
    } else {
      _child = new Center(child: new CircularProgressIndicator());
    }

    List<Widget> children = new List();
    if (_cateLog != null) {
      for (int i = 0; i < _cateLog.length; i++) {
        var cate = _cateLog[i];
        children.add(new Material(
          color: Colors.white,
          child: new InkWell(
              onTap: () {
                _hideCate();
                setState(() {
                  _text = cate.key;
                  _cateRvalue = i;
                });
                FlutterPicker.getItems(_text);
              },
              child: new Container(
                height: 92.0,
                padding: EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 7.0, bottom: 7.0),
                child: new Row(
                  children: [
                    new Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: [
                        new Image(
                          image: new NetworkImage(IMAGE_BG),
                          fit: BoxFit.fill,
                          width: 78.0,
                          height: 78.0,
                        ),
                        new Image.file(
                          new File(cate.image),
                          width: 75.0,
                          height: 75.0,
                          fit: BoxFit.cover,
                        )
                      ],
                    ),
                    new Expanded(
                      child: new Container(
                          margin: EdgeInsets.only(left: 10.0),
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              new Text(
                                cate.key.isEmpty ? "所有图片" : cate.key,
                                style: new TextStyle(fontSize: 16.0),
                              ),
                              new Text(
                                "${cate.number}张",
                                style: new TextStyle(
                                    fontSize: 14.0, color: Colors.grey[600]),
                              )
                            ],
                          )),
                    ),
                    new Radio(
                      value: i,
                      groupValue: _cateRvalue,
                      onChanged: (int value) {
                        _hideCate();

                        setState(() {
                          _text = cate.key;
                          _cateRvalue = i;
                        });
                        FlutterPicker.getItems(cate.key);
                      },
                    )
                  ],
                ),
              )),
        ));
        if (i < _cateLog.length - 1) {
          children.add(new Container(
            color: Color(0xfff1f1f1),
            height: 2.0,
          ));
        }
      }
    }
    //整体布局
    Widget home = new CustomMultiChildLayout(
      delegate: new _SelectorDelegate(),
      children: <Widget>[
        LayoutId(
            id: _SelectorId.lytTop,
            child: new Material(
              color: Colors.blue,
              elevation: 4.0,
              child: new Container(
                padding: EdgeInsets.only(top: 22.5, right: 15.0),
                child: new Row(
                  children: <Widget>[
                    new Material(
                      color: Colors.transparent,
                      child: new InkWell(
                        child: new Container(
                          padding: EdgeInsets.all(15.0),
                          child:
                              new Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    new Expanded(
                        child: new Text(
                      "图片",
                      style: new TextStyle(color: Colors.white, fontSize: 18.0),
                    )),
                    new Container(
                      child: new RaisedButton(
                          onPressed: _selectItems.length == 0
                              ? null
                              : () {
                                  _onChanged(_selectItems);
                                  Navigator.pop(context);
                                },
                          textColor: Colors.white,
                          color: new Color(0xffFF6E40),
                          disabledColor: new Color(0x4fFF6E40),
                          child: new Text(_selectItems.length == 0
                              ? "选择"
                              : "选择(${_selectItems.length}/$_max)")),
                    )
                  ],
                ),
              ),
            )),
        LayoutId(id: _SelectorId.lytCenter, child: _child),
        new LayoutId(
            id: _SelectorId.lytCate,
            child: new Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                new Offstage(
                    child: new Container(color: Color(0xC0000000)),
                    offstage: _hide),
                new Container(
                  height: _height,
                  child: _cateLog == null
                      ? new Center(
                          child: new CircularProgressIndicator(),
                        )
                      : new SingleChildScrollView(
                          child: new Column(children: children),
                        ),
                )
              ],
            )
//            new CustomMultiChildLayout(
//              delegate: new _CateLogDelegate(_distance),
//              children: [
//                new LayoutId(
//                  id: _SelectorId.lytCateLogBg,
//                  child: new Offstage(
//                      child: new Container(color: Color(0xC0000000)),
//                      offstage: _hide),
//                ),
//                new LayoutId(
//                  id: _SelectorId.lytCateLog,
//                  child: _cateLog == null
//                      ? new Center(
//                          child: new CircularProgressIndicator(),
//                        )
//                      : new SingleChildScrollView(
//                          child: new Column(children: children),
//                        ),
//                ),
//              ],
//            )
            ),
        LayoutId(
            id: _SelectorId.lytBottom,
            child: new Container(
              color: Colors.blue,
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new GestureDetector(
                    onTap: () {
                      if (_hide) {
                        _open();
                      } else {
                        _hideCate();
                      }
                    },
                    child: new Row(
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        new Text(
                          _text.isEmpty ? "所有图片" : _text,
                          style: new TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        new Icon(
                          Icons.signal_cellular_4_bar,
                          color: Colors.white,
                          size: 10.0,
                        )
                      ],
                    ),
                  ),
                  new Row(
                    children: <Widget>[
                      new Container(
                        color: Colors.white,
                        width: 1.0,
                        margin: EdgeInsets.only(
                            right: 15.0, bottom: 15.0, top: 15.0),
                      ),
                      new GestureDetector(
                        onTap: () {
                          if (_selectItems.isNotEmpty) {
                            _preview(0, _selectItems, 0);
                          }
                        },
                        child: new Text(
                            _selectItems.isEmpty
                                ? "预览"
                                : "预览(${_selectItems.length})",
                            style: new TextStyle(
                                fontSize: 16.0,
                                color: _selectItems.isEmpty
                                    ? Color(0xffaaaaaa)
                                    : Colors.white)),
                      )
                    ],
                  )
                ],
              ),
            ))
      ],
    );

    //    home
    return new WillPopScope(
      child: new Scaffold(body: Builder(builder: (context) {
        _scaffoldContext = context;
        return home;
      })),
      onWillPop: () {
        return hideOrExit();
      },
    );
  }

  void _showSnackBar(String text) {
    final snackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),
      content: new Text(text),
      action: new SnackBarAction(label: "确定", onPressed: () {}),
    );
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  Future<bool> hideOrExit() async {
    if (_isAnimateShowing) {
      return false;
    }
    if (!_hide) {
      _hideCate();
      return false;
    } else {
      return true;
    }
  }

  void _preview(int index, List<PicItem> picItems, int rvalue,
      [bool isRemove = true]) {
    Navigator.of(this.context)
        .push(new MaterialPageRoute(
            builder: (context) => new PreviewApp(
                index, _max, picItems, _selectItems, rvalue, isRemove)))
        .then((val) {
      bool isSelected = val ?? false;
      if (isSelected) {
        _onChanged(_selectItems);
        Navigator.pop(context);
      }
    });
  }

  Future<void> getImageSize() async {
    int screenWidth = await FlutterPicker.getScreenWidth();
    FlutterPicker.screenWidth = screenWidth;
    int screenHeight = await FlutterPicker.getScreenHeight();
    FlutterPicker.screenHeight = screenHeight;
    double density = await FlutterPicker.getDensity();
    FlutterPicker.density = density;
    if (!mounted) return;
    setState(() {
      _imageSize = (screenWidth - 6.0) / 3;
      _cateHeight = screenHeight - 180.0;
    });
  }

//  Color getBackColor() {
//    switch (_theme) {
//      case THEME_WHITE:
//        return new Color(0xff333333);
//      case THEME_QQ:
//      case THEME_WECHAT:
//        return Colors.white;
//    }
//  }

}

enum _SelectorId {
  lytTop,
  lytBottom,
  lytCenter,
  lytCate,
  lytCateLogBg,
  lytCateLog
}

class _SelectorDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    if (hasChild(_SelectorId.lytTop)) {
      layoutChild(
          _SelectorId.lytTop, new BoxConstraints.tight(Size(size.width, 75.0)));
      positionChild(_SelectorId.lytTop, Offset.zero);
    }
    if (hasChild(_SelectorId.lytCenter)) {
      layoutChild(_SelectorId.lytCenter,
          new BoxConstraints.tight(Size(size.width, size.height - 125.0)));
      positionChild(_SelectorId.lytCenter, Offset(0.0, 75.0));
    }

    if (hasChild(_SelectorId.lytCate)) {
      layoutChild(_SelectorId.lytCate,
          new BoxConstraints.tight(Size(size.width, size.height - 125.0)));
      positionChild(_SelectorId.lytCate, Offset(0.0, 75.0));
    }
    if (hasChild(_SelectorId.lytBottom)) {
      layoutChild(_SelectorId.lytBottom,
          new BoxConstraints.tight(Size(size.width, 50.0)));
      positionChild(_SelectorId.lytBottom, Offset(0.0, size.height - 50.0));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
