import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mykarfour/theme/app_theme.dart';

class PageWidget extends StatefulWidget {
    final String icon;
    final String subtitle;
    final String title;
    const PageWidget({Key key,this.icon,this.title,this.subtitle}) : super(key: key);
    @override
    _PageWidgetState createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget>
    with TickerProviderStateMixin {

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.transparent,
            margin: EdgeInsets.all(25),
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    Lottie.asset(widget.icon,
                        height: 300,),
                    SizedBox(height: 5,),
                    Text(widget.title.toUpperCase(),
                        style: TextStyle(
                            color: AppTheme.buildLightTheme().primaryColor.withOpacity(0.8),
                            fontSize: 30,
                            fontFamily: "WorkSans",
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.bold
                        ),),
                    SizedBox(height: 10,),
                    Text(widget.subtitle,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            fontFamily: "WorkSans",
                            letterSpacing: 0.2,
                            color: AppTheme.buildLightTheme().primaryColor.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,),
                    SizedBox(height: 105,),
                ],
            ),
        );
    }
}
