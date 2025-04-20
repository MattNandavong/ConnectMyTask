import 'package:flutter/material.dart';




class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {



  @override
  Widget build(BuildContext context) {

    return Padding(padding: EdgeInsets.all(12), child: Text('This is meassgae screen.'),);
}

}