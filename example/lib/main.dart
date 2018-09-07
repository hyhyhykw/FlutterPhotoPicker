import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_picker/item.dart';
import 'package:flutter_picker/placeholder_image_view.dart';

void main() => runApp(new MaterialApp(home: new MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  List<PicItem> _picItems;

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (null != _picItems) {
      List<Widget> photos = new List();
      for (int i = 0; i < _picItems.length; i++) {
        var picItem = _picItems[i];
        photos.add(new GestureDetector(
          onTap: _select,
          child: new PlaceHolderImageView(
            imageProvider: new FileImage(new File(picItem.uri)),
            width: 100.0,
            height: 100.0,
            fit: BoxFit.cover,
          ),
        ));
      }
      widget = new GridView.count(
        crossAxisCount: 3,
        children: photos,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
        padding: const EdgeInsets.all(2.0),
      );
    } else {
      widget = new Center(
          child: new RaisedButton(
        onPressed: _select,
        child: new Text("选择"),
      ));
    }

    return new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: widget);
  }

  void _select() {
    PhotoPicker.instance
        .context(context)
        .gif(false)
        .multi(9)
        .selected(_picItems)
        .start((List<PicItem> items) {
      setState(() {
        _picItems = items;
      });
    });

//    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
//      return new SelectorApp(1);
//    }));
  }
}
