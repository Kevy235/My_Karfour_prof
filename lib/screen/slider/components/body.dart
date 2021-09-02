import 'package:flutter/material.dart';
import 'package:mykarfour/screen/accueil/accueil.dart';
import 'package:mykarfour/screen/auth/login_screen.dart';

import '../../../size_config.dart';
import '../../../constant.dart';
import 'slider_content.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  bool passer = false;
  final _controllerPage = PageController();
  static const _kDuration = const Duration(milliseconds: 700);
  static const _kCurve = Curves.ease;

  @override
  void initState() {
    // TODO: implement initState
    this.passer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> splashData = [
      {
        "titre": "APPRENDRE",
        "text": "Plus de 1500 cours clairs \n et structurés",
        "image": "assets/icons/intro1.png"
      },
      {
        "titre": "S'ENTRAINER",
        "text": "Plus de 50.000 exercices et \n leurs corrections et des profs",
        "image": "assets/icons/exercise.png"
      },
      {
        "titre": "PROGRESSER",
        "text": "Des modules d'auto-evaluation \npour se tester et progresser",
        "image": "assets/icons/intro3.png"
      },
      {
        "titre": "REUSSIR",
        "text": "Une année scolaire reussie et \n un succès garranti",
        "image": "assets/icons/intro4.png"
      },
    ];
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Spacer(),
            Expanded(
                flex: 4,
                child: PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                      if (value + 1 == splashData.length) {
                        setState(() {
                          this.passer = true;
                        });
                      } else {
                        setState(() {
                          this.passer = false;
                        });
                      }
                    },
                    controller: _controllerPage,
                    itemCount: splashData.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (index > 0)
                            IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_outlined,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                onPressed: () {
                                  _controllerPage.previousPage(
                                      duration: _kDuration, curve: _kCurve);
                                }),
                          if (index == 0)
                            SizedBox(
                              height: 8,
                              width: 60,
                            ),
                          SliderContent(
                              titre: splashData[index]["titre"].toString(),
                              image: splashData[index]["image"].toString(),
                              text: splashData[index]["text"].toString()),
                          if (index >= 0 && index + 1 != splashData.length)
                            IconButton(
                                icon: Icon(Icons.arrow_forward_ios_outlined,
                                    color: Colors.white, size: 25),
                                onPressed: () {
                                  _controllerPage.nextPage(
                                      duration: _kDuration, curve: _kCurve);
                                }),
                          if (index + 1 == splashData.length)
                            SizedBox(
                              height: 8,
                              width: 45,
                            ),
                        ],
                      );
                    })),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(25)),
                  child: Column(
                    children: [
                      Spacer(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(splashData.length,
                              (index) => buildDot(index: index))),
                      Spacer(
                        flex: 1,
                      ),
                      if (passer)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                    builder: (context) => Accueil(),
                                  ));
                                },
                                child: Text('Passer'),
                                style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(147, 109, 255, 1),
                                    primary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25))),
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
          color: currentPage == index
              ? Color.fromRGBO(79, 50, 170, 1)
              : Color(0xFFD8D8D8),
          borderRadius: BorderRadius.circular(4)),
    );
  }
}
