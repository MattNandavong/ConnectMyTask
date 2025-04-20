
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:mobile/screen/account.dart';
import 'package:app/widget/messages.dart';
import 'package:app/widget/browsetask_screen.dart';
import 'package:app/widget/mytask_screen.dart';
import 'package:app/widget/post_task.dart';

class BottomBar extends StatefulWidget {
  BottomBar({
    super.key,
    required this.changeScreenTo,
    required this.activeScreen,
    // required this.user,
  });
  // final User user;
  final void Function(String) changeScreenTo;
  final String activeScreen;

  static final List<Widget> _widgetOptions = <Widget>[
    PostTask(),
    BrowseTask(),
    MyTaskScreen(),
    MessageScreen(),
    // AccountScreen(user: user),
  ];

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              rippleColor: const Color.fromARGB(255, 230, 248, 241)!,
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
                });
              },
            ),
          ),
        ),
      );
  }
}
