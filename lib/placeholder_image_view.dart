import 'dart:async';

import 'package:flutter/material.dart';

class PlaceHolderImageView extends StatefulWidget {
  const PlaceHolderImageView({
    Key key,
    @required this.imageProvider,
    this.loadingChild,
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);
  final ImageProvider imageProvider;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget loadingChild;

  @override
  State<StatefulWidget> createState() => new _PlaceholderState();
}

class _PlaceholderState extends State<PlaceHolderImageView> {
  @override
  void initState() {
    super.initState();
    _getImage();
  }

  ImageInfo _imageInfo;

  @override
  Widget build(BuildContext context) =>
      _imageInfo == null ? _buildLoading() : _buildImage();

  Future<ImageInfo> _getImage() {
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream =
        widget.imageProvider.resolve(const ImageConfiguration());
    final listener = (ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
        if(!mounted)return;
        setState(() {
          _imageInfo = info;
        });
      }
    };
    stream.addListener(listener);
    completer.future.then((_) {
      stream.removeListener(listener);
    });
    return completer.future;
  }

  Widget _buildLoading() {
    return widget.loadingChild != null
        ? widget.loadingChild
        : Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: const CircularProgressIndicator(),
            ),
          );
  }

  Widget _buildImage() {
    return new Image(
      image: widget.imageProvider,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
