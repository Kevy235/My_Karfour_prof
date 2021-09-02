

class Reply {
  String by;
  String description;
  int time;
  String photoUrl;
  String photoPath;

  Reply(
      {
        this.by="",
        this.description,
        this.time,
        this.photoUrl = '',
        this.photoPath = ''});

  Reply.fromJson(Map<dynamic, dynamic> json) {
    by = json['sender'];
    description = json['description']?? '';
    time = json['timestamp'];
    photoUrl = json['photoUrl'] ?? '';
  }
}