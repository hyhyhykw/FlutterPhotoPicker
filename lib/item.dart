import 'dart:convert' show json;

class BeanWrapper {
  List<PicItem> items;

  BeanWrapper.fromParams({this.items});

  factory BeanWrapper(jsonStr) => jsonStr == null
      ? null
      : jsonStr is String
          ? new BeanWrapper.fromJson(json.decode(jsonStr))
          : new BeanWrapper.fromJson(jsonStr);

  BeanWrapper.fromJson(jsonRes) {
    items = jsonRes['items'] == null ? null : [];

    for (var itemsItem in items == null ? [] : jsonRes['items']) {
      items.add(itemsItem == null ? null : new PicItem.fromJson(itemsItem));
    }
  }

  @override
  String toString() {
    return '{"items": $items}';
  }
}

class PicItem {
  bool selected;
  String uri;

  PicItem.fromParams({this.selected, this.uri});

  PicItem.fromJson(jsonRes) {
    selected = jsonRes['selected'];
    uri = jsonRes['uri'];
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PicItem &&
              runtimeType == other.runtimeType &&
              uri == other.uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() {
    return '{"selected": $selected,"uri": ${uri != null ? '${json.encode(uri)}' : 'null'}}';
  }
}
