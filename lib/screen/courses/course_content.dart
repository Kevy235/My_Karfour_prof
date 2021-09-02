import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mykarfour/model/course.dart';
import 'package:mykarfour/model/shortcut.dart';
import 'package:mykarfour/screen/courses/view_content.dart';
import 'package:http/http.dart' as http;
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:mykarfour/widget/grid_item.dart';

class CourseContentScreen extends StatefulWidget {
  final Course course;
  final dynamic chapter;
  const CourseContentScreen({Key key,this.course,this.chapter}) : super(key: key);
  @override
  _CourseContentScreenState createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  String selectedCourse="";
  List<ShortCut> list=[];
  bool _loading=false;

  @override
  void initState() {
    list=[];
    getData();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  final DbService dbService = new DbService();

  Future<String> get accessToken => dbService.getAccessToken();

  Future<bool> getData() async {
    setState(() {
      _loading=true;
    });
    var url = Apirequest.chapter+widget.chapter["id"].toString();

    final response = await http.get(url,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
          HttpHeaders.acceptHeader: 'application/json',
        });
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      List<dynamic> _list=jsonResponse as List<dynamic>;
      dynamic _obj=_list[0];
      setState(() {
        if((_obj["lessons"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"leçons",image:"assets/icons/course.png",destination: ViewContent(chapter:_obj["lessons"][0]["title"],content:_obj["lessons"][0]["content"])));
        if((_obj["definitions"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Definitions",image:"assets/icons/definition.png",destination: ViewContent(chapter:_obj["definitions"][0]["title"],content:_obj["definitions"][0]["content"])));
        if((_obj["corrected_exercises"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Exercices",image:"assets/icons/exercise.png",destination: ViewContent(chapter:_obj["corrected_exercises"][0]["title"],content:_obj["corrected_exercises"][0]["content"])));
        if((_obj["characters"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Caractères",image:"assets/icons/character.png",destination: ViewContent(chapter:_obj["characters"][0]["title"],content:_obj["characters"][0]["content"])));
        if((_obj["dates"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Dates",image:"assets/icons/history.png",destination: ViewContent(chapter:_obj["dates"][0]["title"],content:_obj["dates"][0]["content"])));
        if((_obj["formulas"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Formules",image:"assets/icons/formula.png",destination: ViewContent(chapter:_obj["formulas"][0]["title"],content:_obj["formulas"][0]["content"])));
        if((_obj["methodologies"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Methodologies",image:"assets/icons/method.png",destination: ViewContent(chapter:_obj["methodologies"][0]["title"],content:_obj["methodologies"][0]["content"])));
        if((_obj["books"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Livres",image:"assets/icons/library.png",destination: ViewContent(chapter:_obj["books"][0]["title"],content:_obj["books"][0]["content"])));
        if((_obj["simulations"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Simulations",image:"assets/icons/simulation.png",destination: ViewContent(chapter:_obj["simulations"][0]["title"],content:_obj["simulations"][0]["content"])));
        if((_obj["schematics"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Schemas",image:"assets/icons/schema.png",destination: ViewContent(chapter:_obj["schematics"][0]["title"],content:_obj["schematics"][0]["content"])));
        if((_obj["demonstrations"] as List<dynamic>).isNotEmpty)
          list.add(new ShortCut(title:"Schemas",image:"assets/icons/demo.png",destination: ViewContent(chapter:_obj["demonstrations"][0]["title"],content:_obj["demonstrations"][0]["content"])));
        _loading=false;
      });
      return true;
    } else {
      setState(() {
        _loading=false;
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
        body: Column(
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
                          padding: const EdgeInsets.only(top: 40),
                          child: list.isNotEmpty?GridView(
                            padding: const EdgeInsets.all(12),
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            children: List<Widget>.generate(
                              list.length,
                                  (int index) {
                                final Animation<double> animation =
                                Tween<double>(begin: 0.0, end: 1.0).animate(
                                    CurvedAnimation(
                                        parent: animationController,
                                        curve: Interval((1 / list.length) * index, 1.0,
                                            curve: Curves.fastOutSlowIn)));
                                animationController.forward();
                                return getButtonUI(list[index].title,list[index].image,list[index].destination,animation);
                              },
                            ),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12.0,
                              crossAxisSpacing: 12.0,
                              childAspectRatio: 0.95,
                            ),
                          ):SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getButtonUI( String title, String image, Widget destination, Animation animation) {
    return Expanded(
      child: GridItem(title: title,image:image,animationController: animationController,animation: animation, destination: destination),
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
                  widget.course.title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: AppTheme.grey,
                  ),
                ),
                Text(
                  widget.chapter['name'],
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
          )
        ],
      ),
    );
  }
}
