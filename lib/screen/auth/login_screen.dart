import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:mykarfour/model/tokens.dart';
import 'package:mykarfour/screen/check_code/check_code.dart';
import 'package:http/http.dart' as http;
import 'package:mykarfour/screen/home_screen/home_screen.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/utils/apirequest.dart';

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);
  final ClientInfo clientInfo=new ClientInfo();
  String authOperation="no_operation";
  String _phone='';
  String _password='';

  DbService dbService=DbService();

  Future<String> login(LoginData data) async {

    String login= data.name;
    String password=data.password;

    var url = Apirequest.login;

    final response = await http.post(
        url,
        body: {
          'phone_number':login,
          'password':password,
          'client_id': clientInfo.id,
          'profil_id':'2',
          'client_secret': clientInfo.secret,
          'grant_type': 'password'
        }
    );
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      dbService.saveUser(jsonResponse["user"]);
      dbService.saveTokens(Tokens.fromJson(jsonResponse["tokens"]));
      authOperation=AuthOperation.logging;
      return null;
    } else {
      return "Mot de passe ou email incorrect";
    }
  }

  Future<String> register(LoginData data) async {

    String login= data.name;
    _phone=data.name;
    String password=data.password;
    _password=data.password;

    var url = Apirequest.register;

    final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          'phone_number':login,
          'password':password,
          'password_confirmation':password,
          'client_id': clientInfo.id,
          'client_secret': clientInfo.secret,
          'grant_type': 'password',
        }),
    );

    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      authOperation=AuthOperation.registering;
      return null;
    } else {
      return "Mot de passe ou email incorrect";
    }
  }

  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) {
      // if (!users.containsKey(name)) {
      //   return 'Cet utilisateur n\'existe pas';
      // }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Mykarfour',
      logo: "",
      onLogin: login,
      onSignup: register,
      emailValidator: (value){
        var mobileNumber = value;
        var regex = new RegExp("^\\+[0-9]");
        var OK = regex.hasMatch(mobileNumber);
        if (OK && mobileNumber.length>10) {
          return null;
        } else {
          return "Format (+XXX...) uniquement";
        }
      },
      messages: LoginMessages(
        usernameHint: "Téléphone",
        passwordHint: "Mot de passe",
        confirmPasswordHint: "Confirmer le mot de passe",
        forgotPasswordButton: "Mot de passe oublié",
        loginButton: "Connexion",
        signupButton: "Inscription",
        recoverPasswordButton: "Récuperer le mot de passe",
        recoverPasswordIntro: "Réinitialiser votre mot de passe ici",
        recoverPasswordDescription: "Nous enverrons votre mot de passe en texte brut à ce compte de messagerie.",
        goBackButton: "Précédent",
        confirmPasswordError: "Mot de passe ne correspondent pas!",
        recoverPasswordSuccess: "Un e-mail a été envoyé",
      ),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            switch(authOperation){
              case AuthOperation.registering:
                return CheckCode(phone:_phone,password: _password,);
              case AuthOperation.logging:
                return HomeScreen();
            }
            print("zerty");
            return null;
            //ClassroomScreen()
            },
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}

abstract class AuthOperation {
  static const registering = "registering";
  static const logging = "logging";
  // static const registering = "registering";
}