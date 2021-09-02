import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mykarfour/interfaces/onactionpostlistener.dart';
import 'package:mykarfour/model/course.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/screen/courses/course_content.dart';
import 'package:mykarfour/screen/profile/settings.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({Key key}) : super(key: key);

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen>
    with TickerProviderStateMixin
    implements OnProfileChangeListener {
  AnimationController animationController;

  static List<dynamic> list = [];
  List<dynamic> finalList = [];
  bool _loading = false;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    getUser();
    getData();
    super.initState();
  }

  final DbService dbService = new DbService();

  Future<String> get accessToken => dbService.getAccessToken();

  User user = User();

  Future<void> getUser() async {
    user = await dbService.getUser();
    setState(() {
      user = user;
    });
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

  SharedPreferences sharedPreferences;
  Future<Null> getSharedPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _classId = sharedPreferences.getInt(DbService.USER_CLASS_ID_KEY);
      print(_classId);
    });
  }

  int _classId;

  Future<bool> getData() async {
    setState(() {
      _loading = true;
    });

    var url = Apirequest.subjects + user.subject_id.toString() + '/chapters';

    final response = await http.get(url, headers: {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.acceptHeader: 'application/json',
    });
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      print(jsonResponse);
      list = (jsonResponse as List<dynamic>)[0]['chapters'] as List<dynamic>;
      setState(() {
        _loading = false;
        finalList = list;
      });
      return true;
    } else {
      setState(() {
        _loading = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: AppTheme.background,
                                              width: 2)),
                                      child: ListView.separated(
                                        separatorBuilder: (_, __) => SizedBox(
                                          height: 5,
                                        ),
                                        primary: false,
                                        itemCount: list.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final int count = list.length > 10
                                              ? 10
                                              : list.length;
                                          final Animation<double>
                                              animation = Tween<double>(
                                                      begin: 0.0, end: 1.0)
                                                  .animate(CurvedAnimation(
                                                      parent:
                                                          animationController,
                                                      curve: Interval(
                                                          (1 / count) * index,
                                                          1.0,
                                                          curve: Curves
                                                              .fastOutSlowIn)));
                                          animationController.forward();

                                          return GestureDetector(
                                              child: chapterView(
                                                  index, list[index]));
                                        },
                                      ),
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
                            labelText: 'Rechercher un cours',
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
                          onChanged: (val) {
                            list = finalList.where((element) => element['name']
                                .toString()
                                .toLowerCase()
                                .contains(val.toLowerCase()));
                          },
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

  Widget chapterView(int index, dynamic chapter) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.all(6),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.background, width: 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Chapitre " + (index + 1).toString(),
              style: TextStyle(
                color: AppTheme.grey,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              chapter["name"],
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CourseContentScreen(
              course:
                  Course(id: user.subject_id, title: user.subject_name ?? ''),
              chapter: chapter),
        ));
      },
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

  @override
  void onProfileChange() {
    getUser();
    getData();
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
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      getSearchBarUI(),
                      _loading?Center(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ):Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.background,width: 2)
                            ),
                            child: ListView.separated(
                              separatorBuilder: (_,__)=>SizedBox(height: 5,),
                              primary: false,
                              itemCount: list.length,
                              itemBuilder: (BuildContext context, int index) {
                                final int count = list.length > 10
                                    ? 10
                                    : list.length;
                                final Animation<double> animation =
                                Tween<double>(begin: 0.0, end: 1.0).animate(
                                    CurvedAnimation(
                                        parent: animationController,
                                        curve: Interval((1 / count) * index, 1.0,
                                            curve: Curves.fastOutSlowIn)));
                                animationController.forward();

                                return GestureDetector(
                                    child:chapterView(index,list[index])
                                );
                              },
                            ),
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