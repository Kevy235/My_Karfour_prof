import 'package:flutter/material.dart';
import 'package:mykarfour/size_config.dart';
import 'package:mykarfour/widget/custom_text.dart';

class Apropos extends StatefulWidget {
  final String coursTitle;

  const Apropos(this.coursTitle);
  @override
  _AproposState createState() => _AproposState(this.coursTitle);
}

class _AproposState extends State<Apropos> {
  String coursTitle;
  _AproposState(this.coursTitle);

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
                    color: Color.fromRGBO(237, 237, 235, 1),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: getProportionateScreenHeight(70),
                        child: Stack(children: [
                          Container(
                            height: getProportionateScreenHeight(70),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(74, 73, 168, 1),
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/bkg_image.png"),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Opacity(
                              opacity: 0.81,
                              child: Container(
                                color: Color.fromRGBO(74, 73, 168, 1),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: Text(coursTitle,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      Expanded(
                          flex: 4,
                          child: ListView(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: getProportionateScreenHeight(250),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/equipe.jpg"),
                                          fit: BoxFit.fitWidth),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: CustomText(
                                      text: "MyKarfour",
                                      size: 30,
                                      colors: Color.fromRGBO(74, 73, 168, 1),
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 8, right: 8),
                                      child: Text(
                                        "Rogatus ad ultimum admissusque in consistorium ambage nulla praegressa inconsiderate et leviter proficiscere inquit ut praeceptum est, Caesar sciens quod si cessaveris, et tuas et palatii tui auferri iubebo prope diem annonas. hocque solo contumaciter dicto subiratus abscessit nec in conspectum eius postea venit saepius arcessitus.",
                                        style: TextStyle(fontSize: 13),
                                        textAlign: TextAlign.justify,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: CustomText(
                                            text: "Nos services",
                                            weight: FontWeight.bold,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Rogatus ad ultimum admissusque in consistorium ambage nulla praegressa inconsiderate et leviter proficiscere inquit ut praeceptum est, Caesar sciens quod si cessaveris, et tuas et palatii tui auferri iubebo prope diem annonas. hocque solo contumaciter dicto subiratus abscessit nec in conspectum eius postea venit saepius arcessitus.",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                    ),
                                  )
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
}
