import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mykarfour/model/announcement.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/utils/apirequest.dart';
import 'package:mykarfour/widget/swipedetector.dart';

class AnnouncementViewer extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementViewer({Key key, this.announcement}) : super(key: key);


  @override
  AnnouncementViewerState createState() => AnnouncementViewerState();
}
  
 class AnnouncementViewerState extends State<AnnouncementViewer>{

   User user=User();
   DbService dbService=DbService();

   Future<void> getUser() async{
     user=await dbService.getUser();
     setState(()  {
       user=user;
     });
   }

   ImageProvider<dynamic> setImage() {
     if (user.photo == 'default' || user.photo == null) {
       return AssetImage("assets/images/userImage.png");
     } else if (user.photo.contains('https')) {
       return NetworkImage(user.photo);
     } else {
       return AssetImage(user.photo);
     }
   }

  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      onSwipeDown: () {
        Navigator.pop(context);
      },
      onSwipeRight: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        body: Container(
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Hero(
                      transitionOnUserGestures: true,
                      tag: widget.announcement.time.toString() + 'row',
                      child: Image(
                        fit: BoxFit.contain,
                        image: NetworkImage(
                          Apirequest.uploadHost+widget.announcement.photoUrl,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Hero(
                        transitionOnUserGestures: false,
                        tag : widget.announcement.time.toString() + 'photo',
                        child: Row(
                          children: <Widget>[
                            //User profile image section
                            CircleAvatar(
                              radius: 25.0,
                              backgroundImage: setImage(),
                              backgroundColor: Colors.transparent,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //Announcement by section
                                Text(
                                  widget.announcement.by,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                //TimeStamp section
                                Text(
                                  DateFormat("MMM d, E").add_jm().format(
                                      DateTime.fromMillisecondsSinceEpoch(widget.announcement.time)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expanded(
                    //   flex: 1,
                    //   child: SingleChildScrollView(
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(
                    //           left: 8.0, right: 8.0, bottom: 5.0, top: 5),
                    //       child: Hero(
                    //         transitionOnUserGestures: false,
                    //         tag: announcement.time.toString() + 'description',
                    //         child: Text(
                    //           announcement.description,
                    //           style: TextStyle(
                    //             fontSize: 15,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                Positioned(
                  left: -0,
                  top: -0,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: MaterialButton(
                      minWidth: 20,
                      height: 10,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
