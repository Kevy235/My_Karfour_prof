import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mykarfour/interfaces/onactionpostlistener.dart';
import 'package:mykarfour/model/message.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/screen/chat/chat_details.dart';
import 'package:mykarfour/screen/profile/settings.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/size_config.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

Future<bool> getData() async {
  await Future<dynamic>.delayed(const Duration(milliseconds: 200));
  return true;
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin
    implements OnProfileChangeListener {
  List<Message> messageList = new List<Message>();
  String _username;
  String _class = '';
  bool _loading = false;

  SharedPreferences sharedPreferences;
  Future<Null> getSharedPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _username = sharedPreferences.getString(DbService.USER_USERNAME_KEY);
      _class = sharedPreferences.getString(DbService.USER_CLASSNAME_KEY);
    });
  }

  void initState() {
    super.initState();
    getSharedPrefs();
    getUser();
    print(messageList);
  }

  @override
  Widget build(BuildContext context) {
    final chatList = Container(
      height: getProportionateScreenHeight(550.0),
      child: buildMessageList(),
    );

    return Container(
      color: AppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromRGBO(74, 73, 168, 1),
                Color.fromRGBO(147, 109, 255, 1)
              ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
              child: SafeArea(
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(237, 237, 235, 1),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 90,
                          child: Stack(children: [
                            Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(74, 73, 168, 1),
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/bkg_image.png"),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Opacity(
                                opacity: 0.81,
                                child: Container(
                                  color: Color.fromRGBO(74, 73, 168, 1),
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, top: 25),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 200,
                                        child: Text(
                                          user.subject_name ?? '',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 200,
                                        child: Text(
                                          user.classroom ?? '',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            letterSpacing: 0.27,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => SettingsPage(
                                        callback: this.onProfileChange,
                                      ),
                                    ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white70,
                                      minRadius: 30.0,
                                      child: CircleAvatar(
                                          radius: 27.0,
                                          backgroundImage: setImage()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                        Expanded(
                          flex: 4,
                          child: _loading
                              ? Center(
                                  child: Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      color: Color.fromRGBO(70, 53, 235, 1),
                                    ),
                                  ),
                                )
                              : Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: FutureBuilder<bool>(
                                      future: getData(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<bool> snapshot) {
                                        if (!snapshot.hasData) {
                                          return const SizedBox();
                                        } else {
                                          return Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 30.0, right: 30.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      chatList
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                        )
                      ],
                    ),
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(Message message, BuildContext context) {
    /* final unreadCount = Positioned(
      bottom: 9.0,
      right: 0.0,
      child: Container(
        height: 25.0,
        width: 25.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.0),
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Text(
            message.unreadMessages.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ); */

    final userImage = InkWell(
      child: Stack(
        children: <Widget>[
          Hero(
            tag: "_image",
            child: Container(
              margin: EdgeInsets.only(right: 8.0, bottom: 10.0),
              height: 70.0,
              width: 70.0,
              decoration: BoxDecoration(
                color: AppTheme.background,
                image: DecorationImage(
                  image: (message.avatar == null ||
                          message.avatar == "" ||
                          message.avatar == "null")
                      ? AssetImage('assets/icons/default_course.png')
                      : NetworkImage(message.avatar),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // message.unreadMessages == 0 ? Container() : unreadCount
        ],
      ),
    );

    final userNameMessage = Expanded(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatDetailsPage(
              studentId: message.interlocutorId,
              studentName: message.name,
              studentImage: message.avatar,
            ),
          ));
        },
        child: Container(
          padding: EdgeInsets.only(
            left: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: message.name,
                child: Text(
                  message.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    fontFamily: 'WorkSans',
                    letterSpacing: 0.27,
                  ),
                ),
              ),
              Text(
                message.lastMessage == null ? "..." : message.lastMessage,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  fontFamily: 'WorkSans',
                  color: Colors.grey.withOpacity(0.6),
                  letterSpacing: 0.27,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 23,
              )
            ],
          ),
        ),
      ),
    );
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[userImage, userNameMessage],
      ),
    );
  }

  Widget buildMessageList() {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child("users/" +
              user.classroom.toString() +
              "/" +
              user.subject_id.toString() +
              "/chat/")
          .orderByChild("timestamp")
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            !snapshot.hasError &&
            snapshot.data.snapshot.value != null) {
          Map<dynamic, dynamic> map =
              snapshot.data.snapshot.value as Map<dynamic, dynamic>;
          print(snapshot.data.snapshot.value);
          messageList = [];
          map.forEach((key, value) {
            messageList.add(new Message(
                value['interlocutor']['photo'],
                value['interlocutor']['name'],
                value['interlocutor']['id'],
                value['interlocutor']['name'],
                value['lastMessage'],
                value['timestamp'],
                value['unReadMessages'] == null ? 0 : value['unReadMessages']));
          });
          messageList.sort((a, b) => a.time.compareTo(b.time));
          // print(messageList);
          return SafeArea(
            child: ListView.separated(
              itemCount: messageList.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                print(messageList.length);
                return _buildChatTile(
                    messageList[messageList.length - index - 1], context);
              },
            ),
          );
        }
        return Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              color: Color.fromRGBO(70, 53, 235, 1),
            ),
          ),
        );
      },
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFB),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(13.0),
                    bottomLeft: Radius.circular(13.0),
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextFormField(
                          style: TextStyle(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.buildLightTheme().primaryColor,
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Rechercher...',
                            border: InputBorder.none,
                            helperStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFB9BABC),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 0.2,
                              color: Color(0xFFB9BABC),
                            ),
                          ),
                          onEditingComplete: () {},
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(Icons.search, color: Color(0xFFB9BABC)),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: SizedBox(),
          )
        ],
      ),
    );
  }

  Widget getAppBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.subject_name ?? '',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: AppTheme.grey,
                  ),
                ),
                Text(
                  user.classroom ?? '',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.27,
                    color: AppTheme.darkerText,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              height: 60.0,
              width: 60.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: setImage(),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    SettingsPage(callback: this.onProfileChange),
              ));
            },
          )
        ],
      ),
    );
  }

  User user = User();
  DbService dbService = DbService();

  Future<void> getUser() async {
    user = await dbService.getUser();
    setState(() {
      user = user;
    });
    print(user.classroom);
    print(user.subject_id);
  }

  ImageProvider<dynamic> setImage() {
    if (user.photo == 'default' || user.photo == null) {
      return AssetImage("assets/images/userImage.png");
    } else if (user.photo.contains('https')) {
      return NetworkImage(user.photo);
    } else {
      return AssetImage(user.photo);
    }
  }

  @override
  void onProfileChange() {
    getUser();
  }
}



/* 
Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            getAppBarUI(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height+40,
                  child: Column(
                    children: <Widget>[
                      getSearchBarUI(),
                      _loading?Center(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ):Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: FutureBuilder<bool>(
                            future: getData(),
                            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              } else {
                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only( left: 30.0, right: 30.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            chatList
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ), */
