import 'package:flutter/material.dart';



class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<NotificationScreen> {



  @override
  Widget build(BuildContext context) {

    return Padding(padding: EdgeInsets.all(12), child: Text('This is Notification screen.'),);
}

}