import 'dart:convert';

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
  List<Widget>? _widgetOptions;
  List<GButton>? _tabs;
  int _selectedIndex = 0;
  late TopBar _topBar;
  String role = '';

  @override
  void initState() {
    super.initState();
    _topBar = TopBar(screen: 'Loading...');
    _loadUserAndSetupTabs();
  }

  Future<void> _loadUserAndSetupTabs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    if (token == null || userJson == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
      return;
    }

    final user = jsonDecode(userJson);
    setState(() {
      role = user['role'];

      _widgetOptions = [
        if (role == 'user') PostTask(),
        BrowseTask(),
        MyTaskScreen(),
        MessageScreen(),
        NotificationScreen(),
      ];

      _tabs = [
        if (role == 'user') GButton(icon: Icons.add_task, text: 'Post Task'),
        GButton(icon: Icons.search, text: 'Browse Task'),
        GButton(icon: Icons.edit_document, text: 'My Task'),
        GButton(icon: Icons.message_outlined, text: 'Messages'),
        GButton(icon: Icons.notifications, text: 'Notification'),
      ];

      _topBar = TopBar(screen: getTabName(_selectedIndex));
    });
  }

  String getTabName(int index) {
    if (role == 'user') {
      return ['Post Task', 'Browse Task', 'My Task', 'Messages', 'Notification'][index];
    } else {
      return ['Browse Task', 'My Task', 'Messages', 'Notification'][index];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wait for initialization
    if (_tabs == null || _widgetOptions == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 255, 253),
      appBar: _topBar,
      drawer: DrawerMenu(),
      body: Center(
        child: _widgetOptions![_selectedIndex],
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
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
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
              tabs: _tabs!,
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                  _topBar = TopBar(screen: getTabName(index));
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}


