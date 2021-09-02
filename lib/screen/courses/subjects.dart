import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:mykarfour/model/tokens.dart';
import 'package:mykarfour/screen/home_screen/home_screen.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class Subjects extends StatefulWidget {
  final Map<String,dynamic> map;
  const Subjects({Key key,this.map}) : super(key: key);
  @override
  _SubjectsState createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects>
    with TickerProviderStateMixin {
  AnimationController animationController;
  String selectedSubject="";
  final ClientInfo clientInfo=new ClientInfo();
  List<dynamic> list=[];
  bool _loading=false;
  int _value=2;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }


  Future<bool> getData() async {
    setState(() {
      _loading=true;
    });
    var url = Apirequest.subjects_url;

    final response = await http.get(url);
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      list=jsonResponse['subjects'] as List<dynamic>;
      setState(() {
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

  final DbService dbService = new DbService();

  Future<String> get accessToken => dbService.getAccessToken();
  
  Future<void> completeProfile() async {

   setState(() {
     _loading=true;
   });

    var url = Apirequest.complete_profile;
    Map<String,dynamic> map=widget.map;

   final uploadRequest= http.MultipartRequest('POST', Uri.parse(url));

   Map<String, String> headers = {
     HttpHeaders.contentTypeHeader: 'application/json',
   };

   uploadRequest.headers.addAll(headers);
   if(map["user_id"]!=null)
     uploadRequest.fields["user_id"]=map["user_id"].toString();
   if(map["password"]!=null)
     uploadRequest.fields["password"]=map["password"].toString();
   if(map["first_name"]!=null)
     uploadRequest.fields["first_name"]=map["first_name"].toString();
   uploadRequest.fields["birthday"]='2020-01-01';
   if(map["profil_id"]!=null)
     uploadRequest.fields["profil_id"]=map["profil_id"].toString();
   if(map["email"]!=null)
     uploadRequest.fields["email"]=map["email"].toString();
   if(map["name"]!=null)
     uploadRequest.fields["name"]=map["name"].toString();
   if(map["province"]!=null)
     uploadRequest.fields["province"]=map["province"].toString();
   if(map["school"]!=null)
     uploadRequest.fields["school"]=map["school"].toString();
   print(map["picture"].toString());
   uploadRequest.fields["picture"]=map["picture"].toString();

   String _cvPath=map["cv"].toString();
   List<String> mimeTypeData =null;
   if(_cvPath!=null && _cvPath!="") {
     mimeTypeData=lookupMimeType(_cvPath, headerBytes: [0xFF, 0xD8]).split('/');
   }

   MultipartFile file;

   if(_cvPath!=null && _cvPath!="")
     file = await http.MultipartFile.fromPath("cv", _cvPath,
         contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

   if(_cvPath!=null && _cvPath!=""){
     uploadRequest.files.add(file);
   }
   if(selectedSubject!="")
     uploadRequest.fields["subject_id"]=selectedSubject;
   uploadRequest.fields["cycle_id"]=_value.toString();
   uploadRequest.fields["client_id"]=clientInfo.id;
   uploadRequest.fields["client_secret"]=clientInfo.secret;
   uploadRequest.fields["grant_type"]="password";
   final streamedResponse = await uploadRequest.send();

   try{
     final response = await http.Response.fromStream(streamedResponse);
  
     print(response.statusCode);
     print(response.body);
  
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonResponse = json.decode(response.body);
        print(response.body);
        dbService.saveUser(jsonResponse["user"]);
        dbService.saveTokens(Tokens.fromJson(jsonResponse["tokens"]));
  
        if(widget.map!=null){
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
        }
  
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: new Text("L'Opération a échoué!!!"), backgroundColor: Colors.redAccent));
      }
    }catch(e){
      print(e);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
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
                          padding: const EdgeInsets.only(top: 18),
                          child: FutureBuilder<bool>(
                            future: getData(),
                            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              } else {
                                return GridView(
                                  padding: const EdgeInsets.all(12),
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  children: List<Widget>.generate(
                                    list.length,
                                        (int index) {
                                      return getButtonUI(list[index],selectedSubject==list[index]["id"].toString());
                                    },
                                  ),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 12.0,
                                    crossAxisSpacing: 12.0,
                                    childAspectRatio: 0.95,
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
        ),
      ),
    );
  }

  Widget getButtonUI( dynamic subject, bool isSelected) {
    String txt = subject["name"];
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: isSelected?AppTheme.buildLightTheme().primaryColor:AppTheme.nearlyWhite,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: AppTheme.buildLightTheme().primaryColor)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            onTap: () {
              setState(() {
                selectedSubject=subject["id"].toString();
                if(widget.map!=null)
                  completeProfile();
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
                    color: isSelected?AppTheme.notWhite:AppTheme.buildLightTheme().primaryColor,
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
            width: MediaQuery.of(context).size.width-38,
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
                            labelText: 'Rechercher une matière',
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
                  'Cycle',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: AppTheme.grey,
                  ),
                ),
                DropdownButton(
                value: _value,
                items: [
                  DropdownMenuItem(
                    child: Row(children: [
                      SizedBox(width: 6,),
                      new Text('Lycée',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: _value==2?FontWeight.bold:FontWeight.normal,
                            fontSize: _value==2?22:17,
                            letterSpacing: 0.27,
                            color: AppTheme.darkerText,
                          ))],),
                    value: 2,
                  ),
                  DropdownMenuItem(
                      child: Text("Collège",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: _value==1?FontWeight.bold:FontWeight.normal,
                            fontSize: _value==1?22:17,
                            letterSpacing: 0.27,
                            color: AppTheme.darkerText,
                          )),
                      value: 1
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    _value = value;
                  });
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
