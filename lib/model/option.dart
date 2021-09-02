class Option {
  String value;
  String detail;
  bool correct;
  int id;

  Option({ this.id,this.correct, this.value, this.detail });
  Option.fromMap(Map data) {
    value = data['value'];
    detail = data['detail'] ?? '';
    correct = data['correct'];
  }
}