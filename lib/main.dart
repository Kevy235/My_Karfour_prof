import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mykarfour/screen/class_room/class_room.dart';
import 'package:flutter/material.dart';
import 'package:mykarfour/screen/splash/splash.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isLogged=false;

  SharedPreferences sharedPreferences;
  Future<Null> getSharedPrefs() async {
    sharedPreferences=await SharedPreferences.getInstance();
    setState(() {
      isLogged=sharedPreferences.getInt(DbService.USER_ID_KEY)!=null;
    });
  }


  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MYKARFOUR PROF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: isLogged?ClassroomScreen():SplashHome(),
      // home: ClassroomScreen(),
    );
  }
}
