import 'package:app/widget/login.dart';
import 'package:app/widget/post_task.dart';
import 'package:app/widget/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future <Widget> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      // Navigate to main page if token exists
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PostTask()),
      );
      return PostTask();
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
    
    return Scaffold();
  }
}
