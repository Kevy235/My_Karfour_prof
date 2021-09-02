import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/size_config.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mykarfour/widget/custom_text.dart';

class FormulaScreen extends StatefulWidget {
  const FormulaScreen({Key key}) : super(key: key);

  @override
  _FormulaScreenState createState() => _FormulaScreenState();
}

class _FormulaScreenState extends State<FormulaScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;

  TextEditingController _phoneController = TextEditingController();
  static List<dynamic> list = [];
  bool _loading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    getData();
    super.initState();
  }

  final DbService dbService = new DbService();

  Future<String> get accessToken => dbService.getAccessToken();

  Future<bool> getData() async {
    setState(() {
      _loading = true;
    });
    var url = Apirequest.subscription;

    final response = await http.get(url, headers: {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.acceptHeader: 'application/json',
    });

    print(response.body);
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      list = jsonResponse as List<dynamic>;
      setState(() {
        _loading = false;
      });
      return true;
    } else {
      setState(() {
        _loading = false;
      });
      return false;
    }
  }

  Future<void> pay(String phone, dynamic formula) async {
    setState(() {
      _loading = true;
    });

    String operator = "";
    print(phone.substring(0, 3).length == 3);
    switch (phone.substring(0, 3)) {
      case "06":
        operator = 'MC';
        break;
      case "07":
        operator = 'AM';
        break;
    }

    var url = Apirequest.pay;

    final response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.acceptHeader: 'application/json',
    }, body: {
      "formula_id": formula['id'].toString(),
      "phone_number": phone,
      "operator": "MC"
    });
    if (response.statusCode == 200) {
      print(response.body);
      dynamic jsonResponse = json.decode(response.body);
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text("L'Opération a échoué!!!"),
          backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    color: Color.fromRGBO(74, 73, 168, 1),
                  ),
                  child: ListView(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            child: Image.asset(
                                          "assets/icons/school_image.png",
                                          height:
                                              getProportionateScreenHeight(200),
                                          width:
                                              getProportionateScreenWidth(100),
                                        )),
                                      ],
                                    ),
                                    CustomText(
                                      text: "Toutes nos",
                                      colors: Colors.white,
                                      size: 14,
                                    ),
                                    CustomText(
                                      text: "Formules",
                                      colors: Colors.white,
                                      size: 25,
                                      weight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: getProportionateScreenHeight(120),
                                      width: getProportionateScreenWidth(280),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0.3, 0.3),
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Row(
                                              children: [
                                                CustomText(
                                                  text: "200 EURO/",
                                                  colors: Color.fromRGBO(
                                                      74, 73, 168, 1),
                                                  size: 20,
                                                  weight: FontWeight.bold,
                                                ),
                                                CustomText(
                                                  text: "mois",
                                                  colors: Color.fromRGBO(
                                                      74, 73, 168, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width:
                                                      getProportionateScreenWidth(
                                                          80),
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black,
                                                        offset:
                                                            Offset(0.3, 0.3),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Color.fromRGBO(
                                                        74, 73, 168, 1),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {},
                                                    child: Text('PAYER',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13)),
                                                    style: TextButton.styleFrom(
                                                        primary: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: getProportionateScreenHeight(120),
                                      width: getProportionateScreenWidth(280),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0.3, 0.3),
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Row(
                                              children: [
                                                CustomText(
                                                  text: "200 EURO/",
                                                  colors: Color.fromRGBO(
                                                      74, 73, 168, 1),
                                                  size: 20,
                                                  weight: FontWeight.bold,
                                                ),
                                                CustomText(
                                                  text: "mois",
                                                  colors: Color.fromRGBO(
                                                      74, 73, 168, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width:
                                                      getProportionateScreenWidth(
                                                          80),
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black,
                                                        offset:
                                                            Offset(0.3, 0.3),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Color.fromRGBO(
                                                        74, 73, 168, 1),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {},
                                                    child: Text('PAYER',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13)),
                                                    style: TextButton.styleFrom(
                                                        primary: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: getProportionateScreenHeight(120),
                                      width: getProportionateScreenWidth(280),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0.3, 0.3),
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Row(
                                              children: [
                                                CustomText(
                                                  text: "200 EURO/",
                                                  colors: Color.fromRGBO(
                                                      74, 73, 168, 1),
                                                  size: 20,
                                                  weight: FontWeight.bold,
                                                ),
                                                CustomText(
                                                  text: "mois",
                                                  colors: Color.fromRGBO(
                                                      74, 73, 168, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width:
                                                      getProportionateScreenWidth(
                                                          80),
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black,
                                                        offset:
                                                            Offset(0.3, 0.3),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Color.fromRGBO(
                                                        74, 73, 168, 1),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {},
                                                    child: Text('PAYER',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13)),
                                                    style: TextButton.styleFrom(
                                                        primary: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
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
                  'Toutes nos',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: AppTheme.grey,
                  ),
                ),
                Text(
                  "Formules",
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
        ],
      ),
    );
  }
}
/* 
Container(
      color: AppTheme.nearlyWhite,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: _loading
            ? Center(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(),
                ),
              )
            : Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  getAppBarUI(),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.all(6),
                                  child: ListView.separated(
                                    separatorBuilder: (_, __) => SizedBox(
                                      height: 5,
                                    ),
                                    primary: false,
                                    itemCount: list.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final int count =
                                          list.length > 10 ? 10 : list.length;
                                      final Animation<double> animation =
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(CurvedAnimation(
                                                  parent: animationController,
                                                  curve: Interval(
                                                      (1 / count) * index, 1.0,
                                                      curve: Curves
                                                          .fastOutSlowIn)));
                                      animationController.forward();

                                      return GestureDetector(
                                          child:
                                              formulaView(index, list[index]));
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
              ),
      ),
    );


    
  }

  Widget formulaView(int index, dynamic formula) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppTheme.buildLightTheme().primaryColor.withOpacity(0.3),
              width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                formula["price"] +
                    " " +
                    formula["currency"].toString().toUpperCase(),
                style: TextStyle(
                    color: AppTheme.buildLightTheme().primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "/" + formula["invoice_interval"],
                style: TextStyle(
                    color: AppTheme.buildLightTheme().primaryColor,
                    fontWeight: FontWeight.normal),
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            formula["name"].toString().toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppTheme.buildLightTheme().primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.buildLightTheme().primaryColor,
                          width: 1)),
                  child: Text(
                    "PAYER",
                    style: TextStyle(
                        color: AppTheme.white, fontWeight: FontWeight.normal),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.white,
                      title: RichText(
                        text: TextSpan(
                          text: "confirmez la suscription de ",
                          style: TextStyle(
                              color: AppTheme.darkerText,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400),
                          children: <TextSpan>[
                            TextSpan(
                              text: formula['price'].toString() +
                                  " " +
                                  formula['currency'].toString(),
                              style: TextStyle(
                                  color:
                                      AppTheme.buildLightTheme().primaryColor,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text: " pour la formule ",
                                style: TextStyle(
                                    color: AppTheme.darkerText,
                                    fontSize: 14,
                                    height: 1.3,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400)),
                            TextSpan(
                              text: formula['name'].toString().toUpperCase(),
                              style: TextStyle(
                                  color:
                                      AppTheme.buildLightTheme().primaryColor,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      content: Container(
                        height: 76,
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              // color: Colors.blueAccent.withOpacity(0.5),
                              child: TextField(
                                controller: _phoneController,
                                // enabled: !isPosting,
                                // focusNode: _focusNode,
                                maxLength: null,
                                onChanged: (description) {
                                  setState(() {
                                    // _loading = description == '' ? false : true;
                                  });
                                },
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: AppTheme.border
                                              .withOpacity(0.7))),
                                  labelText: "Téléphone",
                                  hintText: "En format notionnale",
                                  hintStyle: TextStyle(
                                    height: 1.5,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFFB9BABC),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                ),
                              ),
                            ),
                            Text(
                              'Un numero AirtelMoney ou Mobicash',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        Row(
                          children: <Widget>[
                            new FlatButton(
                              child: Text(
                                "Confirmer",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: AppTheme.buildLightTheme().primaryColor,
                              onPressed: () {
                                pay(_phoneController.text, formula);
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                            ),
                            SizedBox(
                              height: 8,
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
 */
