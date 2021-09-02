import 'package:flutter/material.dart';
import 'package:mykarfour/screen/auth/connexion.dart';
import 'package:mykarfour/screen/auth/inscription.dart';
import 'package:mykarfour/size_config.dart';
import 'package:mykarfour/widget/custom_text.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
                  image: DecorationImage(
                      image: AssetImage("assets/images/bkg_image.png"),
                      fit: BoxFit.cover),
                ),
              ),
              Opacity(
                  opacity: 0.70,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color.fromRGBO(70, 53, 235, 1),
                        Color.fromRGBO(111, 56, 255, 1)
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                  )),
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(),
                              Image.asset(
                                "assets/icons/logo.png",
                                height: getProportionateScreenHeight(230),
                                width: getProportionateScreenWidth(250),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: CustomText(
                                  text: "Bienvenue",
                                  colors: Colors.white,
                                  size: 25,
                                  weight: FontWeight.bold,
                                ),
                              ),
                              Text("à",
                                  style: TextStyle(
                                      fontSize: getProportionateScreenWidth(20),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text("MyKarfour",
                                  style: TextStyle(
                                      fontSize: getProportionateScreenWidth(30),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ])),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Divider(
                            color: Color.fromRGBO(147, 109, 255, 1),
                          ),
                          Container(
                            width: double.infinity,
                            height: getProportionateScreenHeight(45),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Connexion()));
                              },
                              child: Center(
                                child: Text(
                                  "CONNEXION",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(147, 109, 255, 1)),
                            width: double.infinity,
                            height: getProportionateScreenHeight(45),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Inscription()));
                              },
                              child: Center(
                                child: Text(
                                  "CREER MON COMPTE",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ]),
          ),
        ),
      ],
    ));
  }
}
