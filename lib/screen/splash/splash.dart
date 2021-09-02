import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mykarfour/screen/accueil/accueil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../size_config.dart';
import '../../widget/custom_text.dart';

class SplashHome extends StatefulWidget {
  @override
  _SplashHomeState createState() => _SplashHomeState();
}

class _SplashHomeState extends State<SplashHome>
    with SingleTickerProviderStateMixin {
  double _progress = 0;
  @override
  void initState() {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (!mounted) return;
      setState(() {
        if (_progress == 1) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Accueil()));
        } else {
          _progress += 0.2;
        }
        /* print(_progress); */
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromRGBO(74, 73, 168, 1),
        Color.fromRGBO(147, 109, 255, 1)
      ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
      child: SafeArea(
        child: Stack(fit: StackFit.expand, children: [
          Container(decoration: BoxDecoration(color: Colors.white)),
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/logo.jpeg",
                              height: getProportionateScreenHeight(290),
                              width: getProportionateScreenWidth(290)),
                          CustomText(
                            text: "MyKarfour",
                            colors: Color.fromRGBO(61, 39, 179, 1),
                            size: 25,
                            weight: FontWeight.bold,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                            child: Container(
                              height: 8,
                              width: getProportionateScreenWidth(260),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                child: LinearPercentIndicator(
                                  width: getProportionateScreenWidth(260),
                                  percent: _progress,
                                  lineHeight: 20,
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  progressColor: Color.fromRGBO(61, 39, 179, 1),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("apprendre autrement"),
                          )
                        ])))
          ])
        ]),
      ),
    ));
  }
}

/* LinearProgressIndicator(
                                  value: _progress,
                                  valueColor: AlwaysStoppedAnimation(
                                      Color.fromRGBO(61, 39, 179, 1)),
                                  backgroundColor:
                                      Color.fromRGBO(215, 215, 215, 1),
                                ) */
