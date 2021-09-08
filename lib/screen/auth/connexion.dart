import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mykarfour/model/tokens.dart';
import 'package:mykarfour/screen/auth/inscription.dart';
import 'package:mykarfour/screen/class_room/class_room.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/size_config.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

class Connexion extends StatefulWidget {
  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final ClientInfo clientInfo = new ClientInfo();
  String authOperation = "no_operation";
  String _phone = '';
  String _password = '';
  bool showprogress;
  bool isPasswordVisible = false;

  final _key = new GlobalKey<FormState>();

  DbService dbService = DbService();

  check() {
    final form = _key.currentState;
    /*  print(form.validate()); */

    if (form.validate()) {
      form.save();
      login();
    } else {
      setState(() {
        showprogress = false;
      });
    }
  }

  /* String validateMobile(String value) {
    String patttern = r'(^(?:[+0])?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.isEmpty) {
      return 'Champ numéro de téléphone est requis';
    } else if (!regExp.hasMatch(value)) {
      return 'Format de numéro incorrect \n (+XXX)';
    }
    return null;
  } */

  Future<String> login() async {
    String login = _phone;
    String password = _password;

    var url = Apirequest.login;

    final response = await http.post(url, body: {
      'phone_number': login,
      'password': password,
      'client_id': clientInfo.id,
      'profil_id': '2',
      'client_secret': clientInfo.secret,
      'grant_type': 'password'
    });
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      print(jsonResponse["user"]);
      dbService.saveUser(jsonResponse["user"]);
      dbService.saveTokens(Tokens.fromJson(jsonResponse["tokens"]));
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ClassroomScreen(),
      ));
      return null;
    } else {
      setState(() {
        showprogress = false;
      });
      faildToast("Mot de passe ou numéro incorrect");
    }
  }

  /* LES MESSAGES DE NOTIFICATION */
  successToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white);
  }

  faildToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }
  /* LES MESSAGES DE NOTIFICATION*/

  @override
  void initState() {
    showprogress = false;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      width: MediaQuery.of(context).size.width,
      child: Stack(
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
                    image: DecorationImage(
                        image: AssetImage("assets/images/bkg_image.png"),
                        fit: BoxFit.cover),
                  ),
                ),
                Opacity(
                    opacity: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(70, 53, 235, 1),
                              Color.fromRGBO(111, 56, 255, 1)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                    )),
                Form(
                  key: _key,
                  child: ListView(children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/icons/logo.png",
                              height: getProportionateScreenHeight(150),
                              width: getProportionateScreenWidth(150),
                            ),
                          ],
                        ),
                        Text("CONNEXION",
                            style: TextStyle(
                                fontSize: getProportionateScreenWidth(25),
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(
                          "Heureux de te revoir !",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 20),
                          child: Container(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (e) {
                                String patttern = r'(^(?:[+0])?[0-9]{10,12}$)';
                                RegExp regExp = new RegExp(patttern);
                                if (e.isEmpty) {
                                  return 'Champ numéro de téléphone est requis';
                                } else if (!regExp.hasMatch(e)) {
                                  return 'Format de numéro incorrect \n (+XXX)';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (e) {
                                setState(() {
                                  _phone = e;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "Téléphone:",
                                labelStyle: TextStyle(
                                    color: Colors.white, fontSize: 14),
                                focusColor: Color.fromRGBO(111, 56, 255, 1),
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(111, 56, 255, 1)),
                                ),
                              ),
                              initialValue: '+241',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 20),
                          child: TextFormField(
                            validator: (e) {
                              if (e.isEmpty) {
                                return "Le champ mot de passe est requis";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (e) {
                              setState(() {
                                _password = e;
                              });
                            },
                            obscureText: isPasswordVisible,
                            obscuringCharacter: '*',
                            decoration: InputDecoration(
                              fillColor: Color.fromRGBO(111, 56, 255, 1),
                              labelText: "Mot de passe:",
                              labelStyle:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              focusColor: Color.fromRGBO(111, 56, 255, 1),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(111, 56, 255, 1)),
                              ),
                              suffixIcon: IconButton(
                                icon: isPasswordVisible
                                    ? Icon(Icons.visibility_off,
                                        color: Colors.white)
                                    : Icon(
                                        Icons.visibility,
                                        color: Colors.white,
                                      ),
                                onPressed: () => setState(() =>
                                    isPasswordVisible = !isPasswordVisible),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: 200,
                          height: 40,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0.3, 0.3),
                              )
                            ],
                            color: Color.fromRGBO(111, 56, 255, 1),
                            gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(70, 53, 235, 1),
                                  Color.fromRGBO(111, 56, 255, 1)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                //show progress indicator on click
                                showprogress = true;
                              });
                              check();
                            },
                            child: showprogress
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      backgroundColor:
                                          Color.fromRGBO(0, 62, 109, 1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text('CONNEXION',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                            style: TextButton.styleFrom(primary: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          child: InkWell(
                            onTap: () {
                              print("ok");
                            },
                            child: Text(
                              "Mot de passe oublié ?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 14),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Pas encore de compte ?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 14),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Inscription()));
                                },
                                child: Text(
                                  "S'inscrire ici !",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ]),
                )
              ]),
            ),
          ),
        ],
      ),
    ));
  }
}
