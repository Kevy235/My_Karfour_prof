import 'package:flutter/material.dart';
import 'package:mykarfour/size_config.dart';
import 'package:mykarfour/widget/custom_text.dart';

class Aide extends StatefulWidget {
  final String coursTitle;

  const Aide(this.coursTitle);
  @override
  _AideState createState() => _AideState(this.coursTitle);
}

class _AideState extends State<Aide> {
  String coursTitle;
  _AideState(this.coursTitle);

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
                        height: 70,
                        child: Stack(children: [
                          Container(
                            height: 70,
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
                            padding: const EdgeInsets.only(left: 15.0, top: 10),
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
                                Row(
                                  children: [
                                    Container(
                                      child: IconButton(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 20, 0),
                                          iconSize: 30,
                                          icon: Icon(
                                            Icons.search,
                                            color: Color.fromRGBO(
                                                237, 237, 235, 1),
                                          ),
                                          onPressed: () {}),
                                    ),
                                  ],
                                )
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
                                  
                                  ListTile(
                                      title: CustomText(
                                        text: 'L\'apprentissage de MyKarfour',
                                        weight: FontWeight.bold,
                                        size: 13,
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      )),
                                  Divider(),
                                  ListTile(
                                      title: CustomText(
                                        text: "L'accès aux contenus",
                                        weight: FontWeight.bold,
                                        size: 13,
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Color.fromRGBO(74, 73, 168, 1),
                                      )),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
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
}
