import 'package:flutter/material.dart';
import 'package:mykarfour/size_config.dart';

class BodyAccueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Spacer(),
          Expanded(
              flex: 4,
              child: Column(children: [
                Spacer(
                  flex: 2,
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/icons/logo.png",
                      height: getProportionateScreenHeight(300),
                      width: getProportionateScreenWidth(250),
                    ),
                  ],
                ),
                Spacer(),
                Text("BIENVENUE !",
                    style: TextStyle(
                        fontSize: getProportionateScreenWidth(30),
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ])),
        ],
      ),
    );
  }
}
