class Report {
  String uid;
  int total;
  dynamic topics;

  Report({ this.uid, this.topics, this.total });

  factory Report.fromMap(Map data) {
    return Report(
      uid: data['uid'],
      total: data['total'] ?? 0,
      topics: data['topics'] ?? {},
    );
  }
}