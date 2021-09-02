import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:mykarfour/screen/profile/profile.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:http/http.dart' as http;

class CheckCode extends StatefulWidget {
  final String phone;
  final String password;
  const CheckCode({Key key, this.phone, this.password}) : super(key: key);

  @override
  _CheckCodeState createState() => _CheckCodeState();
}

class _CheckCodeState extends State<CheckCode> {
  bool _onEditing = true;
  String _code;
  bool _loading = false;

  void check() async {
    _loading = true;
    var url = Apirequest.check_phone;

    final response = await http.post(url, body: {
      'phone_number': widget.phone.toString(),
      'verification_code': _code
    });

    print(response.body.toString());
    if (response.statusCode == 200) {
      dynamic jsonResponse = json.decode(response.body);
      print(response.body.toString());
      _loading = false;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ProfilePage(
            id: jsonResponse['id'].toString(), password: widget.password),
      ));
    } else {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Vérification du code')),
      ),
      body: _loading
          ? Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: LinearProgressIndicator(),
              ),
            )
          : Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Entrez le code',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
                VerificationCode(
                  textStyle: TextStyle(
                      fontSize: 20.0, color: Color.fromRGBO(111, 56, 255, 1)),
                  keyboardType: TextInputType.number,
                  // in case underline color is null it will use primaryColor: Colors.red from Theme
                  underlineColor: Color.fromRGBO(111, 56, 255, 1),
                  length: 6,
                  autofocus: true,
                  // clearAll is NOT required, you can delete it
                  // takes any widget, so you can implement your design
                  clearAll: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'effacer tout',
                      style: TextStyle(
                          fontSize: 14.0,
                          decoration: TextDecoration.underline,
                          color: Color.fromRGBO(111, 56, 255, 1)),
                    ),
                  ),
                  onCompleted: (String value) {
                    setState(() {
                      _code = value;
                      check();
                    });
                  },
                  onEditing: (bool value) {
                    setState(() {
                      _onEditing = value;
                    });
                    if (!_onEditing) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: _onEditing
                        ? Text('Svp entrez tout le code')
                        : Text('Vode code: $_code'),
                  ),
                )
              ],
            ),
    );
  }
}
