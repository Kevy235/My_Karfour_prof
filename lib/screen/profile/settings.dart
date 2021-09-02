import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:mykarfour/interfaces/onactionpostlistener.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/screen/apropos/apropos.dart';
import 'package:mykarfour/screen/auth/connexion.dart';
import 'package:mykarfour/screen/class_room/class_room.dart';
import 'package:mykarfour/screen/formula/formula.dart';
import 'package:mykarfour/screen/help/help.dart';
import 'package:mykarfour/screen/profile/profile.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/size_config.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:mykarfour/widget/custom_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  final Function callback;
  const SettingsPage({Key key, this.callback}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    implements OnProfileChangeListener {
  final DbService dbService = DbService();
  User user = User();

  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool isChangeable = false;

  List<dynamic> list = [
    {
      "icon": "assets/images/whatsapp.png",
      "url": "https://wa.me/message/3FEAY24TMOH4D1"
    },
    {
      "icon": "assets/images/facebook.png",
      "url": "https://www.facebook.com/MyKarfourGabon/"
    },
    {"icon": "assets/images/outbound.png", "url": "+24162914562"},
  ];

  Future<void> getUser() async {
    user = await dbService.getUser();
    setState(() {
      user = user;
    });
  }

  final ClientInfo clientInfo = new ClientInfo();

  Future<String> get accessToken => dbService.getAccessToken();

  Future<void> changePassword() async {
    var url = Apirequest.update_password;

    setState(() {
      loading = true;
    });

    final uploadRequest = http.MultipartRequest('POST', Uri.parse(url));

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    uploadRequest.headers.addAll(headers);
    uploadRequest.fields["current_password"] = _oldPassword.text.trim();
    uploadRequest.fields["password"] = _newPassword.text.trim();
    uploadRequest.fields["password_confirmation"] =
        _confirmPassword.text.trim();
    uploadRequest.fields["client_id"] = clientInfo.id;
    uploadRequest.fields["client_secret"] = clientInfo.secret;
    uploadRequest.fields["grant_type"] = "password";
    final streamedResponse = await uploadRequest.send();

    try {
      final response = await http.Response.fromStream(streamedResponse);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonResponse = json.decode(response.body);
        print(response.body);
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("Le mot de passe a été changé avec succès..."),
            backgroundColor: Colors.blueAccent));
      } else {
        setState(() {
          loading = true;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("L'Opération a échoué!!!"),
            backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = true;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text("L'Opération a échoué!!!"),
          backgroundColor: Colors.redAccent));
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (BuildContext context) {
        return Container(
          height: 110,
          padding: EdgeInsets.all(16),
          child: GridView(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: List<Widget>.generate(
              list.length,
              (int index) {
                return GestureDetector(
                  child: Image.asset(list[index]["icon"]),
                  onTap: () {
                    setState(() {
                      if (index == 2)
                        FlutterPhoneState.startPhoneCall(list[index]['url']);
                      else
                        _launchURL(list[index]['url']);
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 30.0,
              crossAxisSpacing: 90.0,
              childAspectRatio: 0.55,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hr = Divider();
    /* final userStats = Positioned(
      bottom: 10.0,
      left: 40.0,
      right: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildUserStats('CONDISCIPLES', user.students.toString()),
          _buildUserStats('EVOLUTION', '${user.progression}%'),
        ],
      ),
    ); */

    final userImage = Container(
      height: 100.0,
      width: 100.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: setImage(),
          fit: BoxFit.cover,
        ),
        shape: BoxShape.circle,
      ),
    );

    final userNameLocation = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            user.name == null ? "" : user.name,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            user.username ?? '',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.6),
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final userInfo = Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(8.0),
            shadowColor: Colors.white,
            child: Container(
              height: 220.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                child: Row(
                  children: <Widget>[
                    userImage,
                    SizedBox(width: 10.0),
                    userNameLocation
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final secondCard = Padding(
      padding: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(8.0),
        shadowColor: Colors.white,
        child: Container(
          height: 280.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child:
                    _buildIconTile(Icons.person, Colors.blueAccent, 'Profile'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      callback: this.onProfileChange,
                    ),
                  ));
                },
              ),
              hr,
              GestureDetector(
                child: _buildIconTile(Icons.group, Colors.green, 'Ma classe'),
                onTap: () {
                  showModalBottomSheet(
                    elevation: 10,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: ClassroomScreen(),
                    ),
                  );
                },
              ),
              hr,
              GestureDetector(
                child:
                    _buildIconTile(Icons.security, Colors.pink, 'Mot de passe'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.white,
                      title: Icon(
                        Icons.security,
                        color: Colors.pink,
                        size: 50,
                      ),
                      content: SingleChildScrollView(
                        child: Container(
                          height: 200,
                          child: Column(
                            children: [
                              Container(
                                height: 40,
                                // color: Colors.blueAccent.withOpacity(0.5),
                                child: TextField(
                                  controller: _oldPassword,
                                  // enabled: !isPosting,
                                  // focusNode: _focusNode,
                                  maxLength: null,
                                  obscureText: true,
                                  onChanged: (description) {
                                    setState(() {
                                      isChangeable = (_newPassword.text
                                                  .trim()
                                                  .length >
                                              7 &&
                                          _oldPassword.text.trim().length > 7 &&
                                          _confirmPassword.text.trim().length >
                                              7 &&
                                          _newPassword.text.trim() ==
                                              _confirmPassword.text.trim() &&
                                          _newPassword.text.trim() !=
                                              _oldPassword.text.trim());
                                    });
                                  },
                                  keyboardType: TextInputType.visiblePassword,
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
                                    labelText: "Mot de passe  courant",
                                    hintText: "*************",
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
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 40,
                                // color: Colors.blueAccent.withOpacity(0.5),
                                child: TextField(
                                  controller: _newPassword,
                                  // enabled: !isPosting,
                                  // focusNode: _focusNode,
                                  maxLength: null,
                                  onChanged: (description) {
                                    setState(() {
                                      isChangeable = (_newPassword.text
                                                  .trim()
                                                  .length >
                                              7 &&
                                          _oldPassword.text.trim().length > 7 &&
                                          _confirmPassword.text.trim().length >
                                              7 &&
                                          _newPassword.text.trim() ==
                                              _confirmPassword.text.trim() &&
                                          _newPassword.text.trim() !=
                                              _oldPassword.text.trim());
                                    });
                                  },
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
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
                                    labelText: "Nouveau mot de passe",
                                    hintText: "*************",
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
                              SizedBox(height: 20),
                              Container(
                                height: 40,
                                // color: Colors.blueAccent.withOpacity(0.5),
                                child: TextField(
                                  controller: _confirmPassword,
                                  // focusNode: _focusNode,
                                  maxLength: null,
                                  onChanged: (description) {
                                    setState(() {
                                      isChangeable = (_newPassword.text
                                                  .trim()
                                                  .length >
                                              7 &&
                                          _oldPassword.text.trim().length > 7 &&
                                          _confirmPassword.text.trim().length >
                                              7 &&
                                          _newPassword.text.trim() ==
                                              _confirmPassword.text.trim() &&
                                          _newPassword.text.trim() !=
                                              _oldPassword.text.trim());
                                    });
                                  },
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
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
                                    labelText: "Confirmer le mot de passe",
                                    hintText: "*************",
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
                            ],
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        Row(
                          children: <Widget>[
                            new FlatButton(
                              child: Text(
                                "Changer",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: AppTheme.buildLightTheme().primaryColor,
                              onPressed: () {
                                if (isChangeable) changePassword();
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
              hr,
              GestureDetector(
                child: _buildIconTile(
                    Icons.monetization_on, Colors.purpleAccent, 'Abonnement'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FormulaScreen(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );

    final thirdCard = Padding(
      padding: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(8.0),
        shadowColor: Colors.white,
        child: Container(
          height: 295.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: _buildIconTile(Icons.help, Colors.blue, 'Aide'),
                onTap: () {
                  _launchURL('https://http://mykarfour.com/help');
                },
              ),
              hr,
              GestureDetector(
                child: _buildIconTile(
                    Icons.contact_mail, Colors.tealAccent, 'Nous contacter'),
                onTap: () {
                  _bottomSheet(context);
                },
              ),
              hr,
              GestureDetector(
                child:
                    _buildIconTile(Icons.info, Colors.orangeAccent, 'A propos'),
                onTap: () {
                  _launchURL('https://http://mykarfour.com/about');
                },
              ),
              hr,
              GestureDetector(
                child: _buildIconTile(
                    Icons.power_settings_new, Colors.red, 'Deconnexion'),
                onTap: () {
                  dbService.clearAll();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Connexion(),
                      ),
                      (r) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
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
                        height: getProportionateScreenHeight(260),
                        child: Stack(children: [
                          Container(
                            height: getProportionateScreenHeight(260),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(74, 73, 168, 1),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, bottom: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white70,
                                          minRadius: 50.0,
                                          child: CircleAvatar(
                                              radius: 45.0,
                                              backgroundImage: setImage()),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            user.name != null
                                                ? CustomText(
                                                    text:
                                                        user.name.toUpperCase(),
                                                    colors: Colors.white,
                                                    size: 21,
                                                    weight: FontWeight.bold,
                                                  )
                                                : Text(''),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            user.first_name != null
                                                ? CustomText(
                                                    text: user.first_name
                                                        .toUpperCase(),
                                                    colors: Colors.white,
                                                    size: 21,
                                                    weight: FontWeight.bold,
                                                  )
                                                : Text('...'),
                                          ],
                                        ),
                                        Container(
                                          width:
                                              getProportionateScreenWidth(170),
                                          child: CustomText(
                                            text: user.email,
                                            colors: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          flex: 4,
                          child: ListView(
                            padding: EdgeInsets.all(10),
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 40,
                                      width: getProportionateScreenWidth(300),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0.3, 0.3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          /* Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Offres())); */
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                FormulaScreen(),
                                          ));
                                        },
                                        child: Text('DECOUVRIR LES OFFRES',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        style: TextButton.styleFrom(
                                            primary: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 40,
                                      width: getProportionateScreenWidth(300),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0.3, 0.3),
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                            'METTRE A JOUR MON ABONNEMENT',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    74, 73, 168, 1),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        style: TextButton.styleFrom(
                                            primary: Colors.white),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => ProfilePage(
                                            callback: this.onProfileChange,
                                          ),
                                        ));
                                      },
                                      title: CustomText(
                                        text: 'Information personnelles',
                                        weight: FontWeight.bold,
                                        size: 13,
                                      ),
                                      subtitle: CustomText(
                                        text: user.name,
                                        colors: Color.fromRGBO(74, 73, 168, 1),
                                        size: 12,
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      )),
                                  Divider(),
                                  ListTile(
                                      onTap: () {
                                        showModalBottomSheet(
                                          elevation: 10,
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (context) => Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.65,
                                            child: ClassroomScreen(),
                                          ),
                                        );
                                      },
                                      title: CustomText(
                                        text: 'Ma classe',
                                        weight: FontWeight.bold,
                                        size: 13,
                                      ),
                                      subtitle: CustomText(
                                        text: user.classroom,
                                        colors: Color.fromRGBO(74, 73, 168, 1),
                                        size: 12,
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      )),
                                  Divider(),
                                  ListTile(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: AppTheme.white,
                                            title: Icon(
                                              Icons.security,
                                              color: Colors.pink,
                                              size: 50,
                                            ),
                                            content: SingleChildScrollView(
                                              child: Container(
                                                height: 200,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      // color: Colors.blueAccent.withOpacity(0.5),
                                                      child: TextField(
                                                        controller:
                                                            _oldPassword,
                                                        // enabled: !isPosting,
                                                        // focusNode: _focusNode,
                                                        maxLength: null,
                                                        obscureText: true,
                                                        onChanged:
                                                            (description) {
                                                          setState(() {
                                                            isChangeable = (_newPassword.text.trim().length > 7 &&
                                                                _oldPassword.text
                                                                        .trim()
                                                                        .length >
                                                                    7 &&
                                                                _confirmPassword
                                                                        .text
                                                                        .trim()
                                                                        .length >
                                                                    7 &&
                                                                _newPassword
                                                                        .text
                                                                        .trim() ==
                                                                    _confirmPassword
                                                                        .text
                                                                        .trim() &&
                                                                _newPassword
                                                                        .text
                                                                        .trim() !=
                                                                    _oldPassword
                                                                        .text
                                                                        .trim());
                                                          });
                                                        },
                                                        keyboardType:
                                                            TextInputType
                                                                .visiblePassword,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              borderSide: BorderSide(
                                                                  color: AppTheme
                                                                      .border
                                                                      .withOpacity(
                                                                          0.7))),
                                                          labelText:
                                                              "Mot de passe  courant",
                                                          hintText:
                                                              "*************",
                                                          hintStyle: TextStyle(
                                                            height: 1.5,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Color(
                                                                0xFFB9BABC),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          20.0),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      height: 40,
                                                      // color: Colors.blueAccent.withOpacity(0.5),
                                                      child: TextField(
                                                        controller:
                                                            _newPassword,
                                                        // enabled: !isPosting,
                                                        // focusNode: _focusNode,
                                                        maxLength: null,
                                                        onChanged:
                                                            (description) {
                                                          setState(() {
                                                            isChangeable = (_newPassword.text.trim().length > 7 &&
                                                                _oldPassword.text
                                                                        .trim()
                                                                        .length >
                                                                    7 &&
                                                                _confirmPassword
                                                                        .text
                                                                        .trim()
                                                                        .length >
                                                                    7 &&
                                                                _newPassword
                                                                        .text
                                                                        .trim() ==
                                                                    _confirmPassword
                                                                        .text
                                                                        .trim() &&
                                                                _newPassword
                                                                        .text
                                                                        .trim() !=
                                                                    _oldPassword
                                                                        .text
                                                                        .trim());
                                                          });
                                                        },
                                                        obscureText: true,
                                                        keyboardType:
                                                            TextInputType
                                                                .visiblePassword,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              borderSide: BorderSide(
                                                                  color: AppTheme
                                                                      .border
                                                                      .withOpacity(
                                                                          0.7))),
                                                          labelText:
                                                              "Nouveau mot de passe",
                                                          hintText:
                                                              "*************",
                                                          hintStyle: TextStyle(
                                                            height: 1.5,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Color(
                                                                0xFFB9BABC),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          20.0),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Container(
                                                      height: 40,
                                                      // color: Colors.blueAccent.withOpacity(0.5),
                                                      child: TextField(
                                                        controller:
                                                            _confirmPassword,
                                                        // focusNode: _focusNode,
                                                        maxLength: null,
                                                        onChanged:
                                                            (description) {
                                                          setState(() {
                                                            isChangeable = (_newPassword.text.trim().length > 7 &&
                                                                _oldPassword.text
                                                                        .trim()
                                                                        .length >
                                                                    7 &&
                                                                _confirmPassword
                                                                        .text
                                                                        .trim()
                                                                        .length >
                                                                    7 &&
                                                                _newPassword
                                                                        .text
                                                                        .trim() ==
                                                                    _confirmPassword
                                                                        .text
                                                                        .trim() &&
                                                                _newPassword
                                                                        .text
                                                                        .trim() !=
                                                                    _oldPassword
                                                                        .text
                                                                        .trim());
                                                          });
                                                        },
                                                        keyboardType:
                                                            TextInputType
                                                                .visiblePassword,
                                                        obscureText: true,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              borderSide: BorderSide(
                                                                  color: AppTheme
                                                                      .border
                                                                      .withOpacity(
                                                                          0.7))),
                                                          labelText:
                                                              "Confirmer le mot de passe",
                                                          hintText:
                                                              "*************",
                                                          hintStyle: TextStyle(
                                                            height: 1.5,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Color(
                                                                0xFFB9BABC),
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          20.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  new FlatButton(
                                                    child: Text(
                                                      "Changer",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    color: AppTheme
                                                            .buildLightTheme()
                                                        .primaryColor,
                                                    onPressed: () {
                                                      if (isChangeable)
                                                        changePassword();
                                                    },
                                                    shape:
                                                        new RoundedRectangleBorder(
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .circular(
                                                                    30.0)),
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
                                      title: CustomText(
                                        text: 'Mot de passe',
                                        weight: FontWeight.bold,
                                        size: 13,
                                      ),
                                      subtitle: CustomText(
                                        text: 'xxxxxxxxx',
                                        colors: Color.fromRGBO(74, 73, 168, 1),
                                        size: 12,
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      )),
                                  Divider(),
                                  ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Apropos(
                                                    "Qui sommes nous ?")));
                                      },
                                      title: CustomText(
                                        text: 'A propos',
                                        weight: FontWeight.bold,
                                        size: 13,
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      )),
                                  Divider(),
                                  ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Aide("Aide")));
                                      },
                                      title: CustomText(
                                        text: 'Aide',
                                        weight: FontWeight.bold,
                                        size: 13,
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      )),
                                  Divider(),
                                  InkWell(
                                    onTap: () {
                                      dbService.clearAll();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Connexion(),
                                          ),
                                          (r) => false);
                                    },
                                    child: Container(
                                      height: 30,
                                      width: getProportionateScreenWidth(170),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0.3, 0.3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                  dbService.clearAll();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Connexion(),
                      ),
                      (r) => false);
                                        },
                                        child: Text('SE DECONNECTE',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11)),
                                        style: TextButton.styleFrom(
                                            primary: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ))
                    ],
                  ),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(String name, String value) {
    return Column(
      children: <Widget>[
        Text(
          name,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildIconTile(IconData icon, Color color, String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: Container(
        height: 30.0,
        width: 30.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
      trailing: Icon(Icons.chevron_left),
    );
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
    print("listener called first time");
    widget.callback();
  }
}




/*import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'package:mykarfour/interfaces/onactionpostlistener.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/screen/auth/connexion.dart';
import 'package:mykarfour/screen/auth/login_screen.dart';
import 'package:mykarfour/screen/profile/profile.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  final Function callback;
  const SettingsPage({Key key, this.callback}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    implements OnProfileChangeListener {
  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final DbService dbService = DbService();
  User user = User();
  bool loading = false;

  List<dynamic> list = [
    {
      "icon": "assets/images/whatsapp.png",
      "url": "https://wa.me/message/3FEAY24TMOH4D1"
    },
    {
      "icon": "assets/images/facebook.png",
      "url": "https://www.facebook.com/MyKarfourGabon/"
    },
    {"icon": "assets/images/outbound.png", "url": "+24162914562"},
  ];

  Future<void> getUser() async {
    user = await dbService.getUser();
    setState(() {
      user = user;
    });
  }

  final ClientInfo clientInfo = new ClientInfo();

  Future<String> get accessToken => dbService.getAccessToken();

  Future<void> changePassword() async {
    var url = Apirequest.update_password;

    setState(() {
      loading = true;
    });

    final uploadRequest = http.MultipartRequest('POST', Uri.parse(url));

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    uploadRequest.headers.addAll(headers);
    uploadRequest.fields["current_password"] = _oldPassword.text.trim();
    uploadRequest.fields["password"] = _newPassword.text.trim();
    uploadRequest.fields["password_confirmation"] =
        _confirmPassword.text.trim();
    uploadRequest.fields["client_id"] = clientInfo.id;
    uploadRequest.fields["client_secret"] = clientInfo.secret;
    uploadRequest.fields["grant_type"] = "password";
    final streamedResponse = await uploadRequest.send();

    try {
      final response = await http.Response.fromStream(streamedResponse);

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic jsonResponse = json.decode(response.body);
        print(response.body);
        setState(() {
          loading = false;
        });
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("Le mot de passe a été changé avec succès..."),
            backgroundColor: Colors.blueAccent));
      } else {
        setState(() {
          loading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("L'Opération a échoué!!!"),
            backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text("L'Opération a échoué!!!"),
          backgroundColor: Colors.redAccent));
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (BuildContext context) {
        return Container(
          height: 110,
          padding: EdgeInsets.all(16),
          child: GridView(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: List<Widget>.generate(
              list.length,
              (int index) {
                return GestureDetector(
                  child: Image.asset(list[index]["icon"]),
                  onTap: () {
                    setState(() {
                      if (index == 2)
                        FlutterPhoneState.startPhoneCall(list[index]['url']);
                      else
                        _launchURL(list[index]['url']);
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 30.0,
              crossAxisSpacing: 90.0,
              childAspectRatio: 0.55,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hr = Divider();

    final userImage = Container(
      height: 100.0,
      width: 100.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: setImage(),
          fit: BoxFit.cover,
        ),
        shape: BoxShape.circle,
      ),
    );

    final userNameLocation = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            user.name ?? "",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            user.subject_name ?? '',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.6),
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final userInfo = Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(8.0),
            shadowColor: Colors.white,
            child: Container(
              height: 190.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                child: Row(
                  children: <Widget>[
                    userImage,
                    SizedBox(width: 10.0),
                    userNameLocation
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final secondCard = Padding(
      padding: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(8.0),
        shadowColor: Colors.white,
        child: Container(
          height: 130.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child:
                    _buildIconTile(Icons.person, Colors.blueAccent, 'Profile'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      callback: this.onProfileChange,
                    ),
                  ));
                },
              ),
              hr,
              GestureDetector(
                child:
                    _buildIconTile(Icons.security, Colors.pink, 'Mot de passe'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      bool isChangeable = false;
                      return AlertDialog(
                        backgroundColor: AppTheme.white,
                        title: Icon(
                          Icons.security,
                          color: Colors.pink,
                          size: 50,
                        ),
                        content: SingleChildScrollView(
                          child: Container(
                            height: 200,
                            child: Column(
                              children: [
                                Container(
                                  height: 40,
                                  // color: Colors.blueAccent.withOpacity(0.5),
                                  child: TextField(
                                    controller: _oldPassword,
                                    // enabled: !isPosting,
                                    // focusNode: _focusNode,
                                    maxLength: null,
                                    obscureText: true,
                                    onChanged: (description) {
                                      setState(() {
                                        isChangeable = (_newPassword.text
                                                    .trim()
                                                    .length >
                                                7 &&
                                            _oldPassword.text.trim().length >
                                                7 &&
                                            _confirmPassword.text
                                                    .trim()
                                                    .length >
                                                7 &&
                                            _newPassword.text.trim() ==
                                                _confirmPassword.text.trim() &&
                                            _newPassword.text.trim() !=
                                                _oldPassword.text.trim());
                                      });
                                    },
                                    keyboardType: TextInputType.visiblePassword,
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
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: AppTheme.border
                                                  .withOpacity(0.7))),
                                      labelText: "Mot de passe  courant",
                                      hintText: "*************",
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
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 40,
                                  // color: Colors.blueAccent.withOpacity(0.5),
                                  child: TextField(
                                    controller: _newPassword,
                                    // enabled: !isPosting,
                                    // focusNode: _focusNode,
                                    maxLength: null,
                                    onChanged: (description) {
                                      setState(() {
                                        isChangeable = (_newPassword.text
                                                    .trim()
                                                    .length >
                                                7 &&
                                            _oldPassword.text.trim().length >
                                                7 &&
                                            _confirmPassword.text
                                                    .trim()
                                                    .length >
                                                7 &&
                                            _newPassword.text.trim() ==
                                                _confirmPassword.text.trim() &&
                                            _newPassword.text.trim() !=
                                                _oldPassword.text.trim());
                                      });
                                    },
                                    obscureText: true,
                                    keyboardType: TextInputType.visiblePassword,
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
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: AppTheme.border
                                                  .withOpacity(0.7))),
                                      labelText: "Nouveau mot de passe",
                                      hintText: "*************",
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
                                SizedBox(height: 20),
                                Container(
                                  height: 40,
                                  // color: Colors.blueAccent.withOpacity(0.5),
                                  child: TextField(
                                    controller: _confirmPassword,
                                    // focusNode: _focusNode,
                                    maxLength: null,
                                    onChanged: (description) {
                                      setState(() {
                                        isChangeable = (_newPassword.text
                                                    .trim()
                                                    .length >
                                                7 &&
                                            _oldPassword.text.trim().length >
                                                7 &&
                                            _confirmPassword.text
                                                    .trim()
                                                    .length >
                                                7 &&
                                            _newPassword.text.trim() ==
                                                _confirmPassword.text.trim() &&
                                            _newPassword.text.trim() !=
                                                _oldPassword.text.trim());
                                      });
                                    },
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: true,
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
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: AppTheme.border
                                                  .withOpacity(0.7))),
                                      labelText: "Confirmer le mot de passe",
                                      hintText: "*************",
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
                                SizedBox(
                                  height: 3,
                                ),
                                loading
                                    ? CircularProgressIndicator()
                                    : SizedBox()
                              ],
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          Row(
                            children: <Widget>[
                              new FlatButton(
                                child: Text(
                                  "Changer",
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: AppTheme.buildLightTheme().primaryColor,
                                onPressed: () {
                                  if (isChangeable) changePassword();
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
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    final thirdCard = Padding(
      padding: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(8.0),
        shadowColor: Colors.white,
        child: Container(
          height: 295.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: _buildIconTile(Icons.help, Colors.blue, 'Aide'),
                onTap: () {
                  _launchURL('https://http://mykarfour.com/help');
                },
              ),
              hr,
              GestureDetector(
                child: _buildIconTile(
                    Icons.contact_mail, Colors.tealAccent, 'Nous contacter'),
                onTap: () {
                  _bottomSheet(context);
                },
              ),
              hr,
              GestureDetector(
                child:
                    _buildIconTile(Icons.info, Colors.orangeAccent, 'A propos'),
                onTap: () {
                  _launchURL('https://http://mykarfour.com/about');
                },
              ),
              hr,
              GestureDetector(
                child: _buildIconTile(
                    Icons.power_settings_new, Colors.red, 'Deconnexion'),
                onTap: () {
                  dbService.clearAll();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Connexion(),
                      ),
                      (r) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height: 310.0,
                      ),
                      Container(
                        height: 250.0,
                        decoration:
                            BoxDecoration(gradient: AppTheme.primaryGradient),
                      ),
                      Positioned(top: 100, right: 0, left: 0, child: userInfo)
                    ],
                  ),
                  secondCard,
                  thirdCard
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(String name, String value) {
    return Column(
      children: <Widget>[
        Text(
          name,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildIconTile(IconData icon, Color color, String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: Container(
        height: 30.0,
        width: 30.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
      trailing: Icon(Icons.chevron_left),
    );
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
    widget.callback();
  }
}
*/