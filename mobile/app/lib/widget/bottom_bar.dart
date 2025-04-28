import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/widget/messages.dart';
import 'package:app/widget/browsetask_screen.dart';
import 'package:app/widget/mytask_screen.dart';
import 'package:app/widget/screen/post_task.dart';

class BottomBar extends StatefulWidget {
  BottomBar({
    super.key,
    required this.changeScreenTo,
    required this.activeScreen,
  });

  final void Function(String) changeScreenTo;
  final String activeScreen;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  String? role;

  final List<GButton> userTabs = [
    GButton(icon: Icons.add_task, text: 'Post Task'),
    GButton(icon: Icons.edit_document, text: 'My Task'),
    GButton(icon: Icons.message_outlined, text: 'Messages'),
    GButton(icon: Icons.notifications, text: 'Notification'),
  ];

  final List<GButton> providerTabs = [
    GButton(icon: Icons.add_task, text: 'Browse Task'),
    GButton(icon: Icons.edit_document, text: 'My Task'),
    GButton(icon: Icons.message_outlined, text: 'Messages'),
    GButton(icon: Icons.notifications, text: 'Notification'),
  ];

  List<GButton> tabs = [];
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    tabs.clear();
    screens.clear();
    _loadRoleAndTabs();
  }

  Future<void> _loadRoleAndTabs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final user = jsonDecode(userString);
      final fetchedRole = user['role'];

      setState(() {
        role = fetchedRole;

        // IMPORTANT: clear previous lists
        tabs = [];
        screens = [];
        if (role == 'user') {
          tabs = userTabs;
          screens = [
            PostTask(),
            MyTaskScreen(),
            MessageScreen(),
            Center(child: Text("Notifications")),
          ];
        } else {
          tabs = providerTabs;
          screens = [
            BrowseTask(),
            MyTaskScreen(),
            MessageScreen(),
            Center(child: Text("Notifications")),
          ];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role == null) {
      return Center(
        child: CircularProgressIndicator(),
      ); // Wait until role loads
    }

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: GNav(
              rippleColor: Color.fromARGB(255, 230, 248, 241)!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Color.fromARGB(255, 6, 123, 51),
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Color.fromARGB(255, 96, 101, 97),
              tabs: tabs,
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
