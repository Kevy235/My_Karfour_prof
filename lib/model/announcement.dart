

import 'package:mykarfour/model/reply.dart';

class Announcement {
  String id;
  String by;
  String description;
  int time;
  String photoUrl;
  String photoPath;
  List<Reply> replies;

  Announcement(
      {
        this.id,
        this.by="",
        this.description,
        this.time,
        this.photoUrl = '',
        this.photoPath = '',
        this.replies});

  Announcement.fromJson(String _id,Map<dynamic, dynamic> json) {
    id=_id;
    by = json['sender'];
    description = json['description']?? '';
    time = json['timestamp'];
    photoUrl = json['photoUrl'] ?? '';
    Map<dynamic,dynamic> map=(json['replies']??Map<dynamic,dynamic>()) as Map<dynamic,dynamic>;
    replies=[];
    map.forEach((key, value) { replies.add(Reply.fromJson(value));});
  }
}