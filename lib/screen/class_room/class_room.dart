import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/screen/home_screen/home_screen.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:http/http.dart' as http;

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({Key key}) : super(key: key);
  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  String selectedClassroom = "";
  final ClientInfo clientInfo = new ClientInfo();
  bool _loading = false;
  int _value = 2;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getProfile();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  Future<bool> getData() async {
    setState(() {
      _loading = true;
    });

    return null;
  }

  final DbService dbService = new DbService();

  Future<String> get accessToken => dbService.getAccessToken();

  Future<void> changeClass(int selectedClassroom) async {
    setState(() {
      _loading = true;
    });

    dbService.updateClass(_value, selectedClassroom,
        classes.firstWhere((a) => a["id"] == selectedClassroom)["name"]);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => HomeScreen(),
    ));
  }

  User user = User();

  Future<void> getUser() async {
    user = await dbService.getUser();
    setState(() {
      user = user;
      print(user.subject_name);
    });
  }

  List<dynamic> classes = [];

  Future<bool> getProfile() async {
    var url = Apirequest.profil;

    _loading = true;

    final response = await http.get(url, headers: {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.acceptHeader: 'application/json',
    });
    if (response.statusCode == 200) {
      _loading = false;
      dynamic jsonResponse = json.decode(response.body);
      // print(jsonResponse);
      setState(() {
        classes = jsonResponse['0']['classes'] as List<dynamic>;
      });
      getUser();
      return true;
    } else {
      _loading = false;
      return false;
      // return "Mot de passe ou email incorrect";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
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
                                        child: Text("Liste de",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        width: 200,
                                        child: Text('MES CLASSES',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
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
                              : FutureBuilder<bool>(
                                  future: getProfile(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<bool> snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox();
                                    } else {
                                      if (classes.isNotEmpty)
                                        return GridView(
                                          padding: const EdgeInsets.all(12),
                                          physics:
                                              const BouncingScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          children: List<Widget>.generate(
                                            classes.length,
                                            (int index) {
                                              return getButtonUI(
                                                  classes[index]);
                                            },
                                          ),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            mainAxisSpacing: 12.0,
                                            crossAxisSpacing: 12.0,
                                            childAspectRatio: 0.95,
                                          ),
                                        );
                                      else
                                        return user.activated
                                            ? SizedBox()
                                            : Center(
                                                child: Text(
                                                "Votre souscription est en cours de traitement...",
                                              ));
                                    }
                                  },
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

  Widget getButtonUI(dynamic classroom) {
    String txt = classroom["name"];
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: AppTheme.nearlyWhite,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Color.fromRGBO(74, 73, 168, 1))),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            onTap: () {
              setState(() {
                changeClass(classroom['id']);
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, left: 18, right: 18),
              child: Center(
                child: Text(
                  txt,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.27,
                    color: Color.fromRGBO(74, 73, 168, 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width - 38,
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
                            labelText: 'Rechercher une classe',
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
                  'Liste de',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: AppTheme.grey,
                  ),
                ),
                new Text('Mes classes',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.27,
                      color: AppTheme.darkerText,
                    ))
              ],
            ),
          )
        ],
      ),
    );
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
                      _loading?Center(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ):Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: FutureBuilder<bool>(
                            future: getProfile(),
                            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              } else {
                                if(classes.isNotEmpty)
                                  return GridView(
                                    padding: const EdgeInsets.all(12),
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    children: List<Widget>.generate(
                                      classes.length,
                                          (int index) {
                                        return getButtonUI(classes[index]);
                                      },
                                    ),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 12.0,
                                      crossAxisSpacing: 12.0,
                                      childAspectRatio: 0.95,
                                    ),
                                  );
                                else
                                  return user.activated?SizedBox():Center(child: Text("Votre souscription est en cours de traitement...",));
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