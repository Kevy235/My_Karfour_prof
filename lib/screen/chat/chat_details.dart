import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mykarfour/model/chat.dart';
import 'package:mykarfour/model/message.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/widget/chat_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatDetailsPage extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String studentImage;
  final int photo;
  const ChatDetailsPage(
      {Key key,
      this.studentId,
      this.studentName,
      this.studentImage,
      this.photo})
      : super(key: key);
  @override
  ChatDetailsPageState createState() => ChatDetailsPageState();
}

class ChatDetailsPageState extends State<ChatDetailsPage> {
  static final List<String> types = ["text", "image"];
  List<Message> messageList = new List<Message>();
  List<Chat> chatList = new List<Chat>();
  List<dynamic> mediaList = [];
  int _subjectId;
  String _subjectPhoto;
  String _subjectName, _classroom;
  String _chatId;

  TextEditingController _controller;

  void initState() {
    super.initState();
    getSharedPrefs();
    _controller = TextEditingController();
  }

  SharedPreferences sharedPreferences;
  Future<Null> getSharedPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _subjectId = sharedPreferences.getInt(DbService.USER_SUBJECT_ID_KEY);
      _subjectName =
          sharedPreferences.getString(DbService.USER_SUBJECT_NAME_KEY);
      _classroom = sharedPreferences.getString(DbService.USER_CLASSNAME_KEY);
      // _photo=sharedPreferences.getString(USER_IMAGE_KEY);
      _subjectPhoto = "";
      FirebaseDatabase.instance
          .reference()
          .child("users/" +
              _classroom +
              '/' +
              _subjectId.toString() +
              "/chat/" +
              widget.studentName.toString())
          .once()
          .then((snapshot) {
        if (snapshot.value != null)
          FirebaseDatabase.instance
              .reference()
              .child("users/" +
                  _classroom +
                  '/' +
                  _subjectId.toString() +
                  "/chat/" +
                  widget.studentName.toString() +
                  "/unReadMessages")
              .set(0);
      });
      _chatId = _subjectId.toString() + "_" + widget.studentName.toString();
    });
  }

  void send() async {
    final int time = new DateTime.now().millisecondsSinceEpoch;
    String message = _controller.text;
    setState(() {
      chatList.add(new Chat(
          _controller.text,
          DateTime.now().millisecondsSinceEpoch,
          types[0],
          "",
          "",
          "",
          true,
          false,
          false,
          "waiting"));
      _controller.clear();
      mediaList = [];
    });

    FirebaseDatabase.instance
        .reference()
        .child("users/" +
            _classroom +
            '/' +
            _subjectId.toString() +
            "/chat/" +
            widget.studentName.toString() +
            "/")
        .set({
      "lastMessage": message,
      "timestamp": time,
      "sender": _subjectId,
      "chatId": _chatId,
      "interlocutor": {
        "id": widget.studentId,
        "name": widget.studentName,
        "photo": widget.studentImage
      }
    });

    int unReadMessages = await FirebaseDatabase.instance
        .reference()
        .child("users/" +
            _classroom +
            '/' +
            _subjectId.toString() +
            "/chat/" +
            widget.studentName.toString() +
            "/unReadMessages")
        .once()
        .then((snapshot) => snapshot.value);

    FirebaseDatabase.instance
        .reference()
        .child("users/" +
            _classroom +
            '/' +
            widget.studentName.toString() +
            "/chat/" +
            _subjectId.toString() +
            "/")
        .set({
      "lastMessage": message,
      "timestamp": time,
      "sender": _subjectId,
      "unReadMessages": unReadMessages == null ? 1 : unReadMessages + 1,
      "chatId": _chatId,
      "interlocutor": {
        "id": _subjectId,
        "name": _subjectName,
        "photo": _subjectPhoto
      }
    });

    // PushNotificationsManager.push(
    //     {
    //       'body': message,
    //       'title': widget.contact.name,
    //       "vibrate": 1,
    //       "sound": 1,
    //       "tag":'${widget.contact.username}_message'
    //     }
    //     ,PushNotificationsManager.MESSAGE_ACTION
    //     ,pushTo: _subjectId);

    FirebaseDatabase.instance
        .reference()
        .child("Chat/" + _chatId + "/messages/")
        .push()
        .set({
      "amount": 0,
      "containFiles": false,
      "message": message,
      "chatStatus": "sent",
      "timestamp": time,
      "sender": _subjectId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final userImage = InkWell(
      // onTap: () => Navigator.pushNamed(context, userDetailsViewRoute, arguments: user.id),
      child: Hero(
        tag: widget.studentName + "_image",
        child: Container(
          margin: EdgeInsets.only(right: 8.0, bottom: 10.0, top: 10),
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (widget.studentImage == null ||
                      widget.studentImage == "" ||
                      widget.studentImage == "null")
                  ? AssetImage('assets/icons/default_course.png')
                  : NetworkImage(widget.studentImage),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );

    final userName = Hero(
      tag: widget.studentName,
      child: Text(
        widget.studentName,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final appBar = Material(
      elevation: 5.0,
      shadowColor: Colors.grey,
      child: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
            userName,
            userImage
          ],
        ),
      ),
    );

    final textInput = Container(
      padding: EdgeInsets.only(left: 10.0),
      height: 47.0,
      width: deviceWidth * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Ecrivez...',
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    final inputBox = Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60.0,
        width: deviceHeight,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.camera_alt,
                color: Color.fromRGBO(74, 73, 168, 1),
              ),
              iconSize: 32.0,
            ),
            textInput,
            IconButton(
              onPressed: () {
                send();
              },
              icon: Icon(
                Icons.send,
                color: Color.fromRGBO(74, 73, 168, 1),
              ),
              iconSize: 32.0,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: deviceHeight,
            width: deviceWidth,
            child: Column(
              children: <Widget>[
                appBar,
                SizedBox(
                  height: 10.0,
                ),
                Flexible(
                    child: Container(
                  height: MediaQuery.of(context).size.height - 165,
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: MediaQuery.of(context).size.height - 165,
                          child: StreamBuilder(
                            stream: FirebaseDatabase.instance
                                .reference()
                                .child("Chat/${_chatId}/messages/")
                                .orderByChild("timestamp")
                                .onValue,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  !snapshot.hasError &&
                                  snapshot.data.snapshot.value != null) {
                                chatList = [];
                                var map = snapshot.data.snapshot.value
                                    as Map<dynamic, dynamic>;
                                map.forEach((key, value) {
                                  chatList.add(new Chat(
                                      value['message'],
                                      value['timestamp'],
                                      types[0],
                                      "",
                                      "",
                                      "",
                                      _subjectId == value['sender'],
                                      false,
                                      false,
                                      value['chatStatus']));
                                });
                                chatList
                                    .sort((a, b) => a.time.compareTo(b.time));

                                return Column(
                                  children: <Widget>[
                                    Flexible(
                                      child: !snapshot.hasData
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              itemCount: chatList.length,
                                              reverse: true,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                String date = DateFormat(
                                                        'dd MMM yyyy')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            chatList[chatList
                                                                        .length -
                                                                    1 -
                                                                    index]
                                                                .time));
                                                String previousDate = (index ==
                                                        chatList.length - 1)
                                                    ? "no date"
                                                    : DateFormat('dd MMM yyyy')
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                chatList[chatList
                                                                            .length -
                                                                        index -
                                                                        2]
                                                                    .time));
                                                String displayDate = date;
                                                if (DateFormat('dd MMM yyyy')
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                DateTime.now()
                                                                    .millisecondsSinceEpoch)) ==
                                                    date) displayDate = "Today";
                                                if (DateFormat('dd MMM yyyy')
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                DateTime.now()
                                                                    .millisecondsSinceEpoch)) ==
                                                    DateFormat('dd MMM yyyy')
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(DateTime
                                                                    .now()
                                                                .add(
                                                                    new Duration(
                                                                        days:
                                                                            -1))
                                                                .millisecondsSinceEpoch)))
                                                  displayDate = "Yesterday";
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: <Widget>[
                                                    date == previousDate
                                                        ? SizedBox()
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            5.0,
                                                                        bottom:
                                                                            1.5),
                                                                height: 20,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppTheme
                                                                          .buildLightTheme()
                                                                      .primaryColor,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5)),
                                                                ),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(3),
                                                                child: Text(
                                                                    displayDate,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white60,
                                                                        fontSize:
                                                                            11)),
                                                              )
                                                            ],
                                                          ),
                                                    Bubble(
                                                      child:
                                                          // chatList[chatList.length-1-index].type == "text" ?
                                                          Text(
                                                              chatList[chatList
                                                                          .length -
                                                                      1 -
                                                                      index]
                                                                  .message,
                                                              style: TextStyle(
                                                                  color: chatList[chatList.length -
                                                                              1 -
                                                                              index]
                                                                          .isMe
                                                                      ? Color(
                                                                          0xFF7F8FA6)
                                                                      : Colors
                                                                          .white))
                                                      // :CachedNetworkImageProvider("")
                                                      ,
                                                      isMe: chatList[
                                                              chatList.length -
                                                                  1 -
                                                                  index]
                                                          .isMe,
                                                      timestamp: chatList[
                                                              chatList.length -
                                                                  1 -
                                                                  index]
                                                          .time,
                                                      delivered: chatList[
                                                              chatList.length -
                                                                  1 -
                                                                  index]
                                                          .chatStatus,
                                                      isContinuing: false,
                                                    )
                                                  ],
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                );
                              }
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                itemCount: chatList.length,
                                reverse: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return Bubble(
                                    child:
                                        // chatList[chatList.length-1-index].type == "text"
                                        //     ?
                                        Text(
                                            chatList[
                                                    chatList.length - 1 - index]
                                                .message,
                                            style: TextStyle(
                                                color: chatList[
                                                            chatList.length -
                                                                1 -
                                                                index]
                                                        .isMe
                                                    ? Color(0xFF7F8FA6)
                                                    : Colors.white))
                                    // :ImageProvider(""),
                                    ,
                                    isMe: chatList[chatList.length - 1 - index]
                                        .isMe,
                                    timestamp:
                                        chatList[chatList.length - 1 - index]
                                            .time,
                                    delivered:
                                        chatList[chatList.length - 1 - index]
                                            .chatStatus,
                                    isContinuing: false,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          inputBox
        ],
      ),
    );
  }
}
