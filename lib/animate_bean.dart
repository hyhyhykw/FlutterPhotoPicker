import 'dart:convert' show json;

class AnimateBean {
  double value;
  bool isEnd;

  AnimateBean.fromParams({this.value, this.isEnd});

  factory AnimateBean(jsonStr) => jsonStr == null
      ? null
      : jsonStr is String
          ? new AnimateBean.fromJson(json.decode(jsonStr))
          : new AnimateBean.fromJson(jsonStr);

  AnimateBean.fromJson(jsonRes) {
    value = jsonRes['value'];
    isEnd = jsonRes['isEnd'];
  }

  @override
  String toString() {
    return '{"value": $value,"isEnd": $isEnd}';
  }
}
