import 'package:flutter/material.dart';

import '../../size_config.dart';
import 'components/body.dart';

class SliderPage extends StatefulWidget {
  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(children: [
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
                gradient: LinearGradient(colors: [
                  Color.fromRGBO(70, 53, 235, 1),
                  Color.fromRGBO(111, 56, 255, 1)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
            )),
        SafeArea(child: Body())
      ]),
    );
  }
}
