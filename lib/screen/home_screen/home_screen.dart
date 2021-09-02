import 'package:flutter/material.dart';
import 'package:mykarfour/model/user.dart';
import 'package:mykarfour/screen/chat/chat_screen.dart';
import 'package:mykarfour/screen/courses/subjet_screen.dart';
import 'package:mykarfour/screen/notifications/notifications.dart';
import 'package:mykarfour/services/db_service.dart';
import 'package:mykarfour/widget/custom_text.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screen = [
    ChatScreen(),
    SubjectScreen(),
    NotificationsScreen()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final DbService dbService = DbService();
  User user = User();

  Future<void> getUser() async {
    user = await dbService.getUser();
    setState(() {
      user = user;
    });
  }

  @override
  void initState() {
    _currentIndex = 0;
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 72,
        color: Color.fromRGBO(71, 41, 227, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //Bottom navigation first item " Accueil"

            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                child: _currentIndex == 0
                    ? Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_outline_outlined,
                              color: Colors.white,
                              size: 35,
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            CustomText(
                              text: "Elèves",
                              size: 12,
                              colors: Colors.white,
                            )
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_outline_outlined,
                              color: Colors.white70,
                              size: 30,
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            CustomText(
                              text: "Elèves",
                              size: 11,
                              colors: Colors.white70,
                            )
                          ],
                        ),
                      ),
              ),
            ),
            //Bottom navigation third item "Commandés"
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                child: _currentIndex == 1
                    ? Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Icon(Icons.my_library_books_outlined,
                                color: Colors.white, size: 35),
                            SizedBox(
                              height: 1,
                            ),
                            CustomText(
                              text: "Cours",
                              size: 12,
                              colors: Colors.white,
                            )
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          children: [
                            Icon(Icons.my_library_books_outlined,
                                color: Colors.white70, size: 30),
                            SizedBox(
                              height: 1,
                            ),
                            CustomText(
                              text: "Cours",
                              size: 11,
                              colors: Colors.white70,
                            )
                          ],
                        ),
                      ),
              ),
            ),
            //Bottom navigation second item "EN ATTENTE"
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                child: _currentIndex == 2
                    ? Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Icon(Icons.mail_outline,
                                color: Colors.white, size: 35),
                            SizedBox(
                              height: 2,
                            ),
                            CustomText(
                              text: "Notifications",
                              size: 12,
                              colors: Colors.white,
                            )
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          children: [
                            Icon(Icons.mail_outline,
                                color: Colors.white70, size: 30),
                            SizedBox(
                              height: 1,
                            ),
                            CustomText(
                              text: "Notifications",
                              size: 11,
                              colors: Colors.white70,
                            )
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      body: _screen[_currentIndex],
    );
  }

  @override
  void onProfileChange() {
    getUser();
  }
}
