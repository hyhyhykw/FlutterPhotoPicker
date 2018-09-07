import 'dart:convert' show json;

class CateLog {
  List<CatelogItem> catelog;

  CateLog.fromParams({this.catelog});

  factory CateLog(jsonStr) => jsonStr == null
      ? null
      : jsonStr is String
          ? new CateLog.fromJson(json.decode(jsonStr))
          : new CateLog.fromJson(jsonStr);

  CateLog.fromJson(jsonRes) {
    catelog = jsonRes['catelog'] == null ? null : [];

    for (var catelogItem in catelog == null ? [] : jsonRes['catelog']) {
      catelog.add(
          catelogItem == null ? null : new CatelogItem.fromJson(catelogItem));
    }
  }

  @override
  String toString() {
    return '{"catelog": $catelog}';
  }
}

class CatelogItem {
  int number;
  String image;
  String key;

  CatelogItem.fromParams({this.number, this.image, this.key});

  CatelogItem.fromJson(jsonRes) {
    number = jsonRes['number'];
    image = jsonRes['image'];
    key = jsonRes['key'];
  }

  @override
  String toString() {
    return '{"number": $number,"image": ${image != null ? '${json.encode(image)}' : 'null'},"key": ${key != null ? '${json.encode(key)}' : 'null'}}';
  }
}
