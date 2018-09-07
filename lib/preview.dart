import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_picker/item.dart';
import 'package:flutter_picker/key_event.dart';
import 'package:flutter_picker/photo_view/photo_view.dart';
import 'package:flutter_picker/photo_view/photo_view_scale_boundary.dart';
import 'package:flutter_picker/photo_view/photo_view_scale_state.dart';

class PreviewApp extends StatefulWidget {
  final int _index;
  final int _max;
  final List<PicItem> _picItems;
  final List<PicItem> _selectItems;
  final int rvalue;
  final bool isRemove;

  PreviewApp(this._index, this._max, this._picItems, this._selectItems,
      this.rvalue, this.isRemove);

  @override
  State<StatefulWidget> createState() =>
      new _PreviewState(_index, _max, _picItems, _selectItems, rvalue);
}

class _PreviewState extends State<PreviewApp> {
  int _index;
  int _max;
  List<PicItem> _picItems;
  List<PicItem> _selectItems;
  bool _isSelected = false;
  PageController _pageController;
  double distance = 0.0;
  bool _isSingle;
  int _rvalue = 0;
  BuildContext _scaffoldContext;
  bool fullScreen = false;

  _PreviewState(this._index, this._max, this._picItems, this._selectItems, this._rvalue) {
    _pageController = new PageController(initialPage: _index);
    _isSingle = _max == 1;
    _isSelected = _picItems[_index].selected;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> photos = new List();
    for (int i = 0; i < _picItems.length; i++) {
      var picItem = _picItems[i];
      var uri = picItem.uri;
      var file = new File(uri);
      var fileImage = new FileImage(file);
      if (uri.endsWith(".gif")) {
        photos.add(new Image(
          image: fileImage,
        ));
      } else {
        photos.add(new GestureDetector(
          onTap: () {
            if (fullScreen) {
              setState(() {
                fullScreen = false;
              });
            } else {
              setState(() {
                fullScreen = true;
              });
            }
            FlutterPicker.switchFullScreen(fullScreen);
          },
          child: new PhotoView(
            imageProvider: fileImage,
            minScale: PhotoViewScaleBoundary.contained * 0.9,
            maxScale: 6.0,
            backgroundColor: Colors.white,
            listener: new _MyStateListener(this),
          ),
        ));
      }
    }

    return new WillPopScope(child: new Scaffold(
      body: Builder(builder: (context) {
        _scaffoldContext = context;
        return new CustomMultiChildLayout(
          delegate: new _MultiChildLayoutDelegate(),
          children: [
            LayoutId(
                id: _PreviewId.vpgPhoto,
                child: new PageView(
                    children: photos,
                    onPageChanged: _pageChange,
                    physics: distance == 0.0
                        ? new PageScrollPhysics()
                        : new NeverScrollableScrollPhysics(),
                    controller: _pageController)),
            LayoutId(
                id: _PreviewId.lytTop,
                child: new Offstage(
                  offstage: fullScreen,
                  child: new Material(
                    color: Colors.blue,
                    elevation: 4.0,
                    child: new Container(
                      padding: EdgeInsets.only(top: 22.5, right: 15.0),
                      child: new Row(
                        children: [
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
                            "${_index + 1}/${_picItems.length}",
                            style: new TextStyle(
                                color: Colors.white, fontSize: 18.0),
                          )),
                          new Container(
                            child: new RaisedButton(
                              onPressed: _selectItems.length == 0
                                  ? null
                                  : () {
                                      Navigator.of(context).pop(true);
                                    },
                              textColor: Colors.white,
                              color: new Color(0xffFF6E40),
                              disabledColor: new Color(0x8fFF6E40),
                              child: new Text(_selectItems.length == 0
                                  ? "选择"
                                  : "选择(${_selectItems.length}/$_max)"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
            LayoutId(
                id: _PreviewId.lytBottom,
                child: new Offstage(
                    offstage: fullScreen,
                    child: new Container(
                      color: Colors.blue,
                      padding: EdgeInsets.all(15.0),
                      child: new Row(
                        children: [
                          _isSingle
                              ? new Radio(
                                  value: _index,
                                  activeColor: new Color(0xffFF6E40),
                                  groupValue: _rvalue,
                                  onChanged: (int val) {
                                    select(val);
                                  })
                              : new Checkbox(
                                  value: _isSelected,
                                  activeColor: new Color(0xffFF6E40),
                                  onChanged: (checked) {
                                    bool selected;
                                    bool itemSelect;
                                    var picItem = _picItems[_index];
                                    if (checked) {
                                      if (_selectItems.length == _max) {
                                        _showSnackBar("最多只能选择$_max张图片");
                                        selected = false;
                                      } else {
                                        _selectItems.add(picItem);
                                        selected = true;
                                      }
                                      itemSelect = selected;
                                    } else {
                                      _selectItems.remove(picItem);
                                      selected = widget.isRemove;
                                      itemSelect = false;
                                    }
                                    setState(() {
                                      _isSelected = selected;

                                      picItem.selected = itemSelect;
                                    });
                                    if (_selectItems.isEmpty) {
                                      Timer(Duration(milliseconds: 10), () {
                                        Navigator.pop(context);
                                      });
                                    }
                                  }),
                          new Text(
                            "选择",
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ))),
          ],
        );
      }),
    ), onWillPop: () {
      if (fullScreen) {
        FlutterPicker.switchFullScreen(false);
      }
      return new Future.value(true);
    });
  }

  void _showSnackBar(String text) {
    final snackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),
      content: new Text(text),
      action: new SnackBarAction(label: "确定", onPressed: () {}),
    );
    Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
  }

  void _pageChange(int value) {
    setState(() {
      _isSelected = _picItems[value].selected;
      distance = 0.0;
      _index = value;
    });
  }

  void select(int value) {
    setState(() {
      _rvalue = value;
    });
  }
}

enum _PreviewId { vpgPhoto, lytTop, lytBottom }

class _MultiChildLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    if (hasChild(_PreviewId.vpgPhoto)) {
      layoutChild(_PreviewId.vpgPhoto, new BoxConstraints.tight(size));
      positionChild(_PreviewId.vpgPhoto, Offset.zero);
    }

    if (hasChild(_PreviewId.lytTop)) {
      layoutChild(
          _PreviewId.lytTop, new BoxConstraints.tight(Size(size.width, 75.0)));
      positionChild(_PreviewId.lytTop, Offset.zero);
    }
    if (hasChild(_PreviewId.lytBottom)) {
      layoutChild(_PreviewId.lytBottom,
          new BoxConstraints.tight(Size(size.width, 50.0)));
      positionChild(_PreviewId.lytBottom, new Offset(0.0, size.height - 50.0));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}

class _MyStateListener extends StateListener {
  _PreviewState _state;

  _MyStateListener(this._state);

  @override
  void state(double dis) {
    _state.setState(() {
      _state.distance = dis;
    });
  }
}
