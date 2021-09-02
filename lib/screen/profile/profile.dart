import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/screen/class_room/class_room.dart';
import 'package:mykarfour/screen/utils_screen/camera_screen.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:mykarfour/utils/ImageCompress.dart' as CompressImage;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class ProfilePage extends StatefulWidget {
  final String id;
  final String password;
  final Function callback;
  ProfilePage({Key key, this.id, this.password, this.callback})
      : super(key: key);

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool guardiansPanel = false;
  String path = 'default';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        initialDatePickerMode: DatePickerMode.day,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1990),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        _dob.text = picked.toLocal().toString().substring(0, 10);
      });
    }
  }

  TextEditingController _name = TextEditingController();
  TextEditingController _first_name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _province = TextEditingController();
  TextEditingController _school = TextEditingController();
  TextEditingController _dob = TextEditingController();
  int a = 0;

  final ClientInfo clientInfo = new ClientInfo();

  final DbService dbService = DbService();
  User user = User();

  Future<void> getUser() async {
    user = await dbService.getUser();
    setState(() {
      user = user;
      _name.text = user.name;
      _school.text = user.school;
      _dob.text = user.birthday;
      path = user.photo;
      if (user.email != 'mykarfourgabon@gmail.com') _email.text = user.email;
      _province.text = user.province;
      _first_name.text = user.first_name;
    });
  }

  Future<String> get accessToken => dbService.getAccessToken();

  Future<void> updateProfile() async {
    var url = Apirequest.update_profil;

    final uploadRequest = http.MultipartRequest('POST', Uri.parse(url));

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    uploadRequest.headers.addAll(headers);
    if (_first_name.text.trim() != null)
      uploadRequest.fields["first_name"] = _first_name.text.trim();
    uploadRequest.fields["birthday"] =
        _dob.text.trim().isNotEmpty ? _dob.text.trim() : user.province;
    uploadRequest.fields["email"] =
        _email.text.trim().isNotEmpty ? _email.text.trim() : user.email;
    uploadRequest.fields["name"] =
        _name.text.trim().isNotEmpty ? _name.text.trim() : user.name;
    uploadRequest.fields["province"] = _province.text.trim().isNotEmpty
        ? _province.text.trim()
        : user.province;
    uploadRequest.fields["school"] =
        _school.text.trim().isNotEmpty ? _school.text.trim() : user.school;
    uploadRequest.fields["picture"] = path;
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
        dbService.saveUser(jsonResponse["user"]);
        // dbService.saveTokens(Tokens.fromJson(jsonResponse["tokens"]));
        widget.callback();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.white,
            title: Text('Profil mis a jour avec succès'),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  new FlatButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: AppTheme.buildLightTheme().primaryColor,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                  ),
                  SizedBox(
                    height: 8,
                  )
                ],
              )
            ],
          ),
        );
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("L'Opération a échoué!!!"),
            backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text("L'Opération a échoué!!!"),
          backgroundColor: Colors.redAccent));
    }
  }

  Future<void> updateProfileImage() async {
    List<String> mimeTypeData = null;
    if (path != null && path != "") {
      mimeTypeData = lookupMimeType(path, headerBytes: [0xFF, 0xD8]).split('/');
    }

    final imageUploadRequest = http.MultipartRequest(
        'POST', Uri.parse(Apirequest.update_profil_image));

    MultipartFile file;
    final DbService dbService = new DbService();

    if (path != null && path != "")
      file = await http.MultipartFile.fromPath("picture", path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader:
          "Bearer ${await dbService.getAccessToken()}",
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    imageUploadRequest.headers.addAll(headers);

    if (path != null && path != "") {
      imageUploadRequest.files.add(file);
    }
    final streamedResponse = await imageUploadRequest.send();
    if (path != null && path != "")
      try {
        final response = await http.Response.fromStream(streamedResponse);
        print(response.body);
        if (response.statusCode == 200) {
          dynamic jsonResponse = json.decode(response.body);
          setState(() {
            path = Apirequest.uploadHost + jsonResponse["picture"];
            print(path);
            if (widget.password == null) {
              dbService.updateProfilePicture(path);
              widget.callback();
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: new Text("Photo de profil mis à jour avec succés!!"),
                  backgroundColor: Colors.blueAccent));
            }
          });
        } else
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: new Text("L'Opération a échoué!!!"),
              backgroundColor: Colors.redAccent));
      } catch (e) {
        print(e);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("L'Opération a échoué!!!"),
            backgroundColor: Colors.redAccent));
      }
  }

  @override
  void initState() {
    super.initState();
    if (widget.id == null) {
      getUser();
    }
  }

  _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          padding: EdgeInsets.all(16),
          child: Container(
              constraints: BoxConstraints(maxHeight: 150, minHeight: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    height: 100,
                    minWidth: MediaQuery.of(context).size.width / 2.2,
                    child: Icon(
                      Icons.photo_camera,
                      color: Color.fromRGBO(70, 53, 235, 1),
                    ),
                    onPressed: () async {
                      Future<String> path = Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CameraScreen()),
                      );
                      path.then((path) {
                        if (path != null)
                          setState(() {
                            Navigator.pop(context);
                            this.path = path;
                            updateProfileImage();
                          });
                        print('Path' + path);
                      });
                    },
                  ),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width / 2.2,
                    height: 100,
                    child: Icon(
                      Icons.photo_library,
                      color: Color.fromRGBO(70, 53, 235, 1),
                    ),
                    onPressed: () async {
                      String _path = await openFileExplorer(
                        FileType.image,
                        mounted,
                        context,
                      );
                      if (_path != null)
                        setState(() {
                          Navigator.pop(context);
                          path = _path;
                          updateProfileImage();
                        });
                    },
                  ),
                ],
              )),
        );
      },
    );
  }

  floatingButtonPressed() async {
    if (_name.text.isEmpty ||
        _province.text.isEmpty ||
        _dob.text.isEmpty ||
        _school.text.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text("Remplissez les champs obligatoires(*)"),
          backgroundColor: Colors.redAccent));
    } else {
      if (widget.password != null) {
        Map<String, dynamic> map = Map<String, dynamic>();
        map.putIfAbsent("user_id", () => widget.id);
        map.putIfAbsent("password", () => widget.password);
        map.putIfAbsent("first_name", () => _first_name.text);
        map.putIfAbsent("birthday", () => _dob.text);
        map.putIfAbsent("profil_id", () => 3);
        map.putIfAbsent("email", () => _email.text);
        map.putIfAbsent("name", () => _name.text);
        map.putIfAbsent("province", () => _province.text);
        map.putIfAbsent("school", () => _school.text);
        map.putIfAbsent("picture", () => path);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ClassroomScreen(),
        ));
      } else {
        updateProfile();
      }
    }
  }

  Future openFileExplorer(
      FileType _pickingType, bool mounted, BuildContext context,
      {String extension}) async {
    String _path = null;
    if (_pickingType == FileType.image) {
      if (extension == null) {
        File file = await CompressImage.takeCompressedPicture(context);
        if (file != null) _path = file.path;
        if (!mounted) return '';

        return _path;
      } else {
        _path = await FilePicker.platform.pickFiles(
            type: _pickingType,
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png'
            ]).then((value) => value.files.first.path);
        if (!mounted) return '';
        return _path;
      }
    } else if (_pickingType != FileType.custom) {
      try {
        _path = await FilePicker.platform.pickFiles(
            type: _pickingType,
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png'
            ]).then((value) => value.files.first.path);
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return '';

      return _path;
    } else if (_pickingType == FileType.custom) {
      try {
        if (extension == null) extension = 'PDF';
        _path = await FilePicker.platform
            .pickFiles(type: _pickingType, allowedExtensions: [extension]).then(
                (value) => value.files.first.path);
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return '';
      return _path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: TopBar(
      //   title: string.profile,
      //   child: kBackBtn,
      //   onPressed: () {
      //     if (model.state ==
      //         ViewState.Idle) if (Navigator.canPop(context))
      //       Navigator.pop(context);
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save',
        elevation: 20,
        backgroundColor: Colors.green,
        onPressed: () async {
          await floatingButtonPressed();
        },
        child: Icon(Icons.check),
      ),
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
                    image: DecorationImage(
                        image: AssetImage("assets/images/bkg_image.png"),
                        fit: BoxFit.cover),
                  ),
                ),
                Opacity(
                    opacity: 0.91,
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
                SafeArea(
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
                          SizedBox(
                            height: 10,
                          ),
                          buildProfilePhotoWidget(context),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: Column(
                              children: [
                                ProfileFields(
                                  width: MediaQuery.of(context).size.width,
                                  hintText: "Entrez votre nom",
                                  labelText: "Nom*",
                                  controller: _name,
                                ),
                                ProfileFields(
                                  width: MediaQuery.of(context).size.width,
                                  hintText: "Votre prénom...",
                                  labelText: "Prénom",
                                  controller: _first_name,
                                ),
                                ProfileFields(
                                  width: MediaQuery.of(context).size.width,
                                  hintText: 'Votre email...',
                                  labelText: 'Email',
                                  controller: _email,
                                ),
                                Row(
                                  // mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          await _selectDate(context);
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: IgnorePointer(
                                          child: ProfileFields(
                                            labelText: 'Date de naissance*',
                                            textInputType: TextInputType.number,
                                            onChanged: (dob) {
                                              _dob.text = dob;
                                            },
                                            hintText: '',
                                            controller: _dob,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ProfileFields(
                                  width: MediaQuery.of(context).size.width,
                                  hintText: 'Votre école...',
                                  labelText: 'Ecole*',
                                  controller: _school,
                                ),
                                ProfileFields(
                                  width: MediaQuery.of(context).size.width,
                                  hintText: 'Votre province...',
                                  labelText: 'Province*',
                                  controller: _province,
                                ),
                              ],
                            ),
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
    );
  }

  Widget buildProfilePhotoWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxHeight: 150, maxWidth: 150),
          child: Stack(
            children: <Widget>[
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(80)),
                ),
                child: Hero(
                  tag: 'profil',
                  transitionOnUserGestures: true,
                  child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(80)),
                          image: DecorationImage(
                              fit: BoxFit.cover, image: setImage()))),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 45,
                  width: 45,
                  child: Card(
                    elevation: 5,
                    color: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.black38,
                        size: 25,
                      ),
                      onPressed: () async {
                        _bottomSheet(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider<dynamic> setImage() {
    if (path.contains('https')) {
      return NetworkImage(path);
    } else if (path == 'default' || path == null) {
      return AssetImage("assets/images/userImage.png");
    } else {
      return AssetImage(path);
    }
  }
}

class ProfileFields extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Function onChanged;
  final double width;
  final Function onTap;
  final TextInputType textInputType;
  final TextEditingController controller;
  final bool isEditable;

  const ProfileFields(
      {@required this.labelText,
      this.hintText,
      this.onChanged,
      this.controller,
      this.onTap,
      this.textInputType,
      this.isEditable = true,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      // width: width == null ? MediaQuery.of(context).size.width / 2.5 : width,
      child: TextField(
        enabled: isEditable,
        onTap: onTap,
        controller: controller,
        // controller: TextEditingController(text: initialText),
        onChanged: onChanged,
        keyboardType: textInputType ?? TextInputType.text,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white)),
          labelStyle: TextStyle(color: Colors.white),
          focusColor: Colors.white,
          fillColor: Colors.white,
          hintText: hintText,
          labelText: labelText,
          hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        ),
      ),
    );
  }
}


/*import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/screen/courses/subjects.dart';
import 'package:mykarfour/screen/utils_screen/camera_screen.dart';
import 'package:mykarfour/services/client_info.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:mykarfour/utils/ImageCompress.dart' as CompressImage;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class ProfilePage extends StatefulWidget {
  final String id;
  final String password;
  final Function callback;
  ProfilePage({Key key, this.id, this.password, this.callback})
      : super(key: key);

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool guardiansPanel = false;
  String path = 'default';
  String _cvPath;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _name = TextEditingController();
  TextEditingController _first_name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _province = TextEditingController();
  TextEditingController _cv = TextEditingController();
  int a = 0;

  final ClientInfo clientInfo = new ClientInfo();

  final DbService dbService = DbService();
  User user = User();

  Future<void> getUser() async {
    user = await dbService.getUser();
    setState(() {
      user = user;
      _name.text = user.name;
      if (user.email != 'mykarfourgabon@gmail.com') _email.text = user.email;
      _province.text = user.province;
      _first_name.text = user.first_name;
    });
  }

  Future<String> get accessToken => dbService.getAccessToken();

  Future<void> updateProfile() async {
    List<String> mimeTypeData = null;
    if (_cvPath != null && _cvPath != "") {
      mimeTypeData =
          lookupMimeType(_cvPath, headerBytes: [0xFF, 0xD8]).split('/');
    }

    MultipartFile file;

    if (_cvPath != null && _cvPath != "")
      file = await http.MultipartFile.fromPath("cv", _cvPath,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    var url = Apirequest.update_profil;

    final uploadRequest = http.MultipartRequest('POST', Uri.parse(url));

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    if (_cvPath != null && _cvPath != "") {
      uploadRequest.files.add(file);
    }

    uploadRequest.headers.addAll(headers);
    if (_first_name.text.trim() != null)
      uploadRequest.fields["first_name"] = _first_name.text.trim();
    uploadRequest.fields["email"] =
        _email.text.trim().isNotEmpty ? _email.text.trim() : user.email;
    uploadRequest.fields["name"] =
        _name.text.trim().isNotEmpty ? _name.text.trim() : user.name;
    uploadRequest.fields["province"] = _province.text.trim().isNotEmpty
        ? _province.text.trim()
        : user.province;
    uploadRequest.fields["school"] = "mykarfour";
    uploadRequest.fields["picture"] = path;
    uploadRequest.fields["birthday"] = "2020-01-01";
    uploadRequest.fields["profil_id"] = '2';
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
        dbService.saveUser(jsonResponse["user"]);
        // dbService.saveTokens(Tokens.fromJson(jsonResponse["tokens"]));
        widget.callback();
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("Profile mis à jour avec succès!!!"),
            backgroundColor: Colors.blueAccent));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("L'Opération a échoué!!!"),
            backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      print(e);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text("L'Opération a échoué!!!"),
          backgroundColor: Colors.redAccent));
    }
  }

  Future<void> updateProfileImage() async {
    List<String> mimeTypeData = null;
    if (path != null && path != "") {
      mimeTypeData = lookupMimeType(path, headerBytes: [0xFF, 0xD8]).split('/');
    }

    final imageUploadRequest = http.MultipartRequest(
        'POST', Uri.parse(Apirequest.update_profil_image));

    MultipartFile file;

    if (path != null && path != "")
      file = await http.MultipartFile.fromPath("picture", path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer ${await accessToken}",
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    imageUploadRequest.headers.addAll(headers);

    if (path != null && path != "") {
      imageUploadRequest.files.add(file);
    }
    final streamedResponse = await imageUploadRequest.send();
    if (path != null && path != "")
      try {
        final response = await http.Response.fromStream(streamedResponse);
        print(response.body);
        if (response.statusCode == 200) {
          dynamic jsonResponse = json.decode(response.body);
          setState(() {
            path = Apirequest.uploadHost + jsonResponse["picture"];
            print(path);
            if (widget.password == null) {
              dbService.updateProfilePicture(path);
              widget.callback();
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: new Text("Photo de profil mis à jour avec succés!!"),
                  backgroundColor: Colors.blueAccent));
            }
          });
        } else
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: new Text("L'Opération a échoué!!!"),
              backgroundColor: Colors.redAccent));
      } catch (e) {
        print(e);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: new Text("L'Opération a échoué!!!"),
            backgroundColor: Colors.redAccent));
      }
  }

  @override
  void initState() {
    super.initState();
    if (widget.id == null) {
      getUser();
    }
  }

  _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          padding: EdgeInsets.all(16),
          child: Container(
              constraints: BoxConstraints(maxHeight: 150, minHeight: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    height: 100,
                    minWidth: MediaQuery.of(context).size.width / 2.2,
                    child: Icon(
                      Icons.photo_camera,
                      color: AppTheme.grey,
                    ),
                    onPressed: () async {
                      Future<String> path = Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CameraScreen()),
                      );
                      path.then((path) {
                        if (path != null)
                          setState(() {
                            Navigator.pop(context);
                            this.path = path;
                            updateProfileImage();
                          });
                        print('Path' + path);
                      });
                    },
                  ),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width / 2.2,
                    height: 100,
                    child: Icon(
                      Icons.photo_library,
                      color: AppTheme.grey,
                    ),
                    onPressed: () async {
                      String _path = await openFileExplorer(
                        FileType.image,
                        mounted,
                        context,
                      );
                      if (_path != null)
                        setState(() {
                          Navigator.pop(context);
                          path = _path;
                          updateProfileImage();
                        });
                    },
                  ),
                ],
              )),
        );
      },
    );
  }

  floatingButtonPressed() async {
    if (_name.text.isEmpty || _province.text.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: new Text("Remplissez les champs obligatoires(*)"),
          backgroundColor: Colors.redAccent));
    } else {
      if (widget.password != null) {
        Map<String, dynamic> map = Map<String, dynamic>();
        map.putIfAbsent("user_id", () => widget.id);
        map.putIfAbsent("password", () => widget.password);
        map.putIfAbsent("first_name", () => _first_name.text);
        map.putIfAbsent("profil_id", () => '2');
        map.putIfAbsent('cv', () => _cvPath);
        map.putIfAbsent("email", () => _email.text);
        map.putIfAbsent("name", () => _name.text);
        map.putIfAbsent("province", () => _province.text);
        map.putIfAbsent("school", () => 'mykarfour');
        map.putIfAbsent("picture", () => path);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Subjects(map: map),
        ));
      } else {
        updateProfile();
      }
    }
  }

  Future openFileExplorer(
      FileType _pickingType, bool mounted, BuildContext context,
      {String extension}) async {
    String _path = null;
    if (_pickingType == FileType.image) {
      if (extension == null) {
        File file = await CompressImage.takeCompressedPicture(context);
        if (file != null) _path = file.path;
        if (!mounted) return '';

        return _path;
      } else {
        _path = await FilePicker.platform.pickFiles(
            type: _pickingType,
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png'
            ]).then((value) => value.files.first.path);
        if (!mounted) return '';
        return _path;
      }
    } else if (_pickingType != FileType.custom) {
      try {
        _path = await FilePicker.platform.pickFiles(
            type: _pickingType,
            allowedExtensions: ['pdf']).then((value) => value.files.first.path);
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return '';

      return _path;
    } else if (_pickingType == FileType.custom) {
      try {
        if (extension == null) extension = 'PDF';
        _path = await FilePicker.platform
            .pickFiles(type: _pickingType, allowedExtensions: [extension]).then(
                (value) => value.files.first.path);
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return '';
      return _path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: TopBar(
      //   title: string.profile,
      //   child: kBackBtn,
      //   onPressed: () {
      //     if (model.state ==
      //         ViewState.Idle) if (Navigator.canPop(context))
      //       Navigator.pop(context);
      //   },
      // ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save',
        elevation: 20,
        backgroundColor: Colors.blueGrey,
        onPressed: () async {
          await floatingButtonPressed();
        },
        child: Icon(Icons.check),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              // fit: StackFit.loose,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                buildProfilePhotoWidget(context),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ProfileFields(
                        width: MediaQuery.of(context).size.width,
                        hintText: "Entrez votre nom",
                        labelText: "Nom*",
                        controller: _name,
                      ),
                      ProfileFields(
                        width: MediaQuery.of(context).size.width,
                        hintText: "Votre prénom...",
                        labelText: "Prénom",
                        controller: _first_name,
                      ),
                      ProfileFields(
                        width: MediaQuery.of(context).size.width,
                        hintText: 'Votre email...',
                        labelText: 'Email',
                        controller: _email,
                      ),
                      Row(
                        // mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                _cvPath = await openFileExplorer(
                                    FileType.custom, mounted, context,
                                    extension: 'PDF');
                                setState(() {
                                  _cv.text = _cvPath != null
                                      ? _cvPath.split('/').last
                                      : '...';
                                });
                                print(_cv.text);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: IgnorePointer(
                                child: ProfileFields(
                                  width: MediaQuery.of(context).size.width,
                                  hintText: 'Votre CV...',
                                  labelText: 'Votre CV...',
                                  controller: _cv,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ProfileFields(
                        width: MediaQuery.of(context).size.width,
                        hintText: 'Votre province...',
                        labelText: 'Province*',
                        controller: _province,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfilePhotoWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
          child: Stack(
            children: <Widget>[
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Hero(
                  tag: 'profileeee',
                  transitionOnUserGestures: true,
                  child: Image(
                      height: MediaQuery.of(context).size.width / 2.5,
                      width: MediaQuery.of(context).size.width / 2.5,
                      fit: BoxFit.contain,
                      image: setImage()),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 45,
                  width: 45,
                  child: Card(
                    elevation: 5,
                    color: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.black38,
                        size: 25,
                      ),
                      onPressed: () async {
                        _bottomSheet(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider<dynamic> setImage() {
    if (path.contains('https')) {
      return NetworkImage(path);
    } else if (path == 'default' || path == null) {
      return AssetImage("assets/images/userImage.png");
    } else {
      return AssetImage(path);
    }
  }
}

class ProfileFields extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Function onChanged;
  final double width;
  final Function onTap;
  final TextInputType textInputType;
  final TextEditingController controller;
  final bool isEditable;

  const ProfileFields(
      {@required this.labelText,
      this.hintText,
      this.onChanged,
      this.controller,
      this.onTap,
      this.textInputType,
      this.isEditable = true,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      // width: width == null ? MediaQuery.of(context).size.width / 2.5 : width,
      child: TextField(
        enabled: isEditable,
        onTap: onTap,
        controller: controller,
        // controller: TextEditingController(text: initialText),
        onChanged: onChanged,
        keyboardType: textInputType ?? TextInputType.text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          hintText: hintText,
          labelText: labelText,
          hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        ),
      ),
    );
  }

  Future openFileExplorer(
      FileType _pickingType, bool mounted, BuildContext context,
      {String extension}) async {
    String _path = null;
    if (_pickingType == FileType.image) {
      if (extension == null) {
        File file = await CompressImage.takeCompressedPicture(context);
        if (file != null) _path = file.path;
        if (!mounted) return '';

        return _path;
      } else {
        _path = await FilePicker.platform.pickFiles(
            type: _pickingType,
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png'
            ]).then((value) => value.files.first.path);
        if (!mounted) return '';
        return _path;
      }
    } else if (_pickingType != FileType.custom) {
      try {
        _path = await FilePicker.platform.pickFiles(
            type: _pickingType,
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png'
            ]).then((value) => value.files.first.path);
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return '';

      return _path;
    } else if (_pickingType == FileType.custom) {
      try {
        if (extension == null) extension = 'PDF';
        _path = await FilePicker.platform
            .pickFiles(type: _pickingType, allowedExtensions: [extension]).then(
                (value) => value.files.first.path);
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return '';
      return _path;
    }
  }
}
*/