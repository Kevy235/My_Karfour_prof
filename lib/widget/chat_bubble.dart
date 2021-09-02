import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mykarfour/theme/app_theme.dart';

enum ChatStatus { blocked, waiting, requested, accepted }
enum MessageType { text, image }

class Bubble extends StatelessWidget {
  const Bubble(
      {@required this.child,
        @required this.timestamp,
        @required this.delivered,
        @required this.isMe,
        @required this.isContinuing});

  final int timestamp;
  final Widget child;
  final dynamic delivered;
  final bool isMe, isContinuing;

  humanReadableTime() => DateFormat('h:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

  getSeenStatus(seen) {
    if (seen is bool) return true;
    if (seen is String) return true;
    return timestamp <= seen;
  }

  @override
  Widget build(BuildContext context) {
    final bg = isMe ?Colors.white: AppTheme.buildLightTheme().accentColor;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    dynamic icon;
    switch(delivered){
      case "seen":
        icon=Icon(Icons.done_all, size: 13.0, color: AppTheme.dark_grey);
        break;
      case "delivered":
        icon=Icon(Icons.done_all, size: 13.0, color: Color(0xFF7F8FA6));
        break;
      case "sent":
        icon=Icon(Icons.done, size: 13.0, color: Color(0xFF7F8FA6));
        break;
      default:
        icon=Icon(Icons.access_time, size: 13.0, color: Color(0xFF7F8FA6));
        break;
    }

    final color =  isMe?Color(0xFF7F8FA6):Colors.white;
    dynamic radius = isMe
        ? BorderRadius.only(
          topLeft: Radius.circular(5.0),
          bottomLeft: Radius.circular(5.0),
          bottomRight: Radius.circular(5.0),
        )
        : BorderRadius.only(
          topRight: Radius.circular(5.0),
          bottomLeft: Radius.circular(5.0),
          bottomRight: Radius.circular(5.0),
        );
    dynamic margin = const EdgeInsets.only(top: 5.0, bottom: 5.5);
    if (isContinuing) {
      radius = BorderRadius.all(Radius.circular(5.0));
      margin = const EdgeInsets.all(1.5);
    }

    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: align,
          children: <Widget>[
            Container(
              margin: margin,
              padding: const EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
              ),
              child: Stack(
                children: <Widget>[
                  Padding(
                      padding: child is Container
                          ? EdgeInsets.all(0.0)
                          : EdgeInsets.only(right: isMe ? 65.0 : 50.0),
                      child: child),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: Row(
                      children: <Widget>[
                        Text(humanReadableTime().toString() + (isMe ? ' ' : ''),
                            style: TextStyle(
                              color: color,
                              fontSize: 10.0,
                            )),
                        isMe ? icon : null
                      ].where((o) => o != null).toList(),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
