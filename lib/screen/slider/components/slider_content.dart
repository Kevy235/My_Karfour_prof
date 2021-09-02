import 'package:flutter/material.dart';

import '../../../size_config.dart';

class SliderContent extends StatelessWidget {
  const SliderContent({
    Key key,
    this.titre,
    this.text,
    this.image,
  }) : super(key: key);

  final String titre, text, image;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Spacer(
            flex: 2,
          ),
          Image.asset(
            image,
            height: getProportionateScreenHeight(300),
            width: getProportionateScreenWidth(230),
          ),
          Spacer(),
          Text(titre,
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(30),
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
