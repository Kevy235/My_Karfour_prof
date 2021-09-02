import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mykarfour/screen/auth/connexion.dart';
import 'package:mykarfour/screen/check_code/check_code.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/size_config.dart';
import 'package:mykarfour/utils/apirequest.dart';

import 'package:http/http.dart' as http;

class Inscription extends StatefulWidget {
  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  bool checkValue = false;
  final ClientInfo clientInfo = new ClientInfo();
  String authOperation = "no_operation";
  String _phone = '';
  String _password = '', _cpassword = '', errorPolicyMessage = "";
  bool showprogress, validationPolicy;
  bool isPasswordVisible = false;
  bool isPasswordVisibleConf = false;
  final _key = new GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();

  DbService dbService = DbService();

  check() {
    final form = _key.currentState;

    if (!checkValue) {
      setState(() {
        errorPolicyMessage = 'Vous devez accepter nos termes d\'utilisation';
      });
    } else {
      setState(() {
        errorPolicyMessage = '';
      });
    }

    if (form.validate() && checkValue) {
      form.save();
      register();
    } else {
      setState(() {
        showprogress = false;
      });
    }
  }

  Future<String> register() async {
    String login = _phone;
    String password = _password;

    var url = Apirequest.register;

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'phone_number': login,
        'password': password,
        'password_confirmation': password,
        'client_id': clientInfo.id,
        'client_secret': clientInfo.secret,
        'grant_type': 'password',
      }),
    );

    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => CheckCode(
                phone: _phone,
                password: _password,
              )));
      return null;
    } else {
      return "Mot de passe ou email incorrect";
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
    validationPolicy = false;
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
                  child: ListView(
                    children: [
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
                          Container(
                            width: getProportionateScreenWidth(250),
                            child: Text(
                              "Vous et vos amis toujours connectés",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 40, right: 40),
                            child: TextFormField(
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
                                    color: Colors.white, fontSize: 16),
                                focusColor: Color.fromRGBO(111, 56, 255, 1),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(111, 56, 255, 1)),
                                ),
                              ),
                              initialValue: '+241',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40, right: 40),
                            child: TextFormField(
                              controller: _pass,
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
                              decoration: InputDecoration(
                                fillColor: Color.fromRGBO(111, 56, 255, 1),
                                labelText: "Mot de passe:",
                                labelStyle: TextStyle(
                                    color: Colors.white, fontSize: 16),
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
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40, right: 40),
                            child: TextFormField(
                              validator: (e) {
                                if (e.isEmpty) {
                                  return "Le champ confirmer mot de passe est requis";
                                } else if (e != _pass.text) {
                                  return "Pas de correspondance";
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (e) {
                                setState(() {
                                  _cpassword = e;
                                });
                              },
                              obscureText: isPasswordVisibleConf,
                              decoration: InputDecoration(
                                fillColor: Color.fromRGBO(111, 56, 255, 1),
                                labelText: "Confirme le mot de passe:",
                                labelStyle: TextStyle(
                                    color: Colors.white, fontSize: 16),
                                focusColor: Color.fromRGBO(111, 56, 255, 1),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(111, 56, 255, 1)),
                                ),
                                suffixIcon: IconButton(
                                  icon: isPasswordVisibleConf
                                      ? Icon(Icons.visibility_off,
                                          color: Colors.white)
                                      : Icon(
                                          Icons.visibility,
                                          color: Colors.white,
                                        ),
                                  onPressed: () => setState(() =>
                                      isPasswordVisibleConf =
                                          !isPasswordVisibleConf),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30, right: 20),
                            child: Row(children: [
                              Checkbox(
                                  checkColor: Color.fromRGBO(111, 56, 255, 1),
                                  activeColor: Colors.white,
                                  value: checkValue,
                                  onChanged: (value) {
                                    print(value);
                                    setState(() {
                                      checkValue = value;
                                    });
                                  }),
                              Text(
                                "J'accepte les termes, les conditions \n et la politique de confidentialité ",
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 13),
                              ),
                            ]),
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 20),
                              child: Text(errorPolicyMessage,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  )))
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text('S\'INSCRIRE',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                style:
                                    TextButton.styleFrom(primary: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Vous avez déjà un compte? ",
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
                                          builder: (context) => Connexion()));
                                },
                                child: Text(
                                  "Connexion",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ]),
            ),
          ),
        ],
      ),
    ));
  }
}
