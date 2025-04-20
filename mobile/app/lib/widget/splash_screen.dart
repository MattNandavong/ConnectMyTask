import 'package:app/widget/browsetask_screen.dart';
import 'package:app/widget/drawer_menu.dart';
import 'package:app/widget/login.dart';
import 'package:app/widget/messages.dart';
import 'package:app/widget/mytask_screen.dart';
import 'package:app/widget/notification.dart';
import 'package:app/widget/post_task.dart';

import 'package:app/widget/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

   final List<Widget> _widgetOptions = <Widget>[
    PostTask(),
    BrowseTask(),
    MyTaskScreen(),
    MessageScreen(),
    NotificationScreen(),
  ];
  var  _selectedIndex =0;
  TopBar _topBar = TopBar(screen: 'Post Task');
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _topBar = TopBar(screen: 'Post Task');
  }

  Future <Widget> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      // Navigate to main page if token exists
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => PostTask()),
      // );
      // return PostTask();
      return SplashScreen();
    } else {
      // Navigate to login page if no token
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 255, 253),
      appBar:  _topBar,
      drawer: DrawerMenu(),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical:8),
            child: GNav(
              rippleColor: const Color.fromARGB(255, 230, 248, 241),
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: const Color.fromARGB(255, 6, 123, 51),
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: const Color.fromARGB(255, 96, 101, 97),
              tabs: [
                GButton(
                  padding: EdgeInsets.all(5),
                  icon: Icons.add_task,
                  text: 'Post Task',
                ),
                GButton(
                  padding: EdgeInsets.all(5),
                  icon: Icons.search,
                  text: 'Browse Task',
                ),
                GButton(
                  padding: EdgeInsets.all(5),
                  icon: Icons.edit_document,
                  text: 'My task',
                ),
                GButton(
                  padding: EdgeInsets.all(5),
                  icon: Icons.message_outlined,
                  text: 'Messages',
                ),
                GButton(
                  padding: EdgeInsets.all(5),
                  icon: Icons.notifications,
                  text: 'Notification',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                  switch (index) {
                    case 0:
                      _topBar = TopBar(screen: 'Post Task');
                    case 1:
                      _topBar = TopBar(screen: 'Browse Task');
                    case 2:
                      _topBar = TopBar(screen: 'My Task');
                    case 3:
                      _topBar = TopBar(screen: 'Messages');
                    case 4:
                      _topBar = TopBar(screen: 'Notification');
                      break;
                    default:
                  }
                  
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
