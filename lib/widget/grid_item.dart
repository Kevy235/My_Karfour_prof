import 'dart:io';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mykarfour/theme/app_theme.dart';

class GridItem extends StatelessWidget {
  const GridItem(
      {Key key,
        this.title,
        this.image,
        this.destination,
        this.animationController,
        this.animation,})
      : super(key: key);

  final String title;
  final String image;
  final Widget destination;
  final AnimationController animationController;
  final Animation<dynamic> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Container(
            height: 150,
            child: Transform(
              transform: Matrix4.translationValues(
                  0.0, 100 * (1.0 - animation.value), 0.0),
              child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => destination,
                    ));
                  },
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.all(Radius.circular(16.0)),
                    child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          color: AppTheme.background,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(image, height: 100,
                              width: 100,),
                              SizedBox(height: 15,),
                              Text(
                                title,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  fontSize: 12,
                                  letterSpacing: 0.27,
                                  color: AppTheme
                                      .grey,
                                ),
                              )
                            ],
                          ),
                        )),
                  )
              ),
            ),
          ),
        );
      },
    );
  }
}