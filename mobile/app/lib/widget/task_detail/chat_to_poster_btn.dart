import 'package:app/model/task.dart';
import 'package:app/widget/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatToPosterBtn extends StatelessWidget {
  final Task task;
  final String currentUserId;
  const ChatToPosterBtn({super.key, required this.task, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // builder: (_) => ChatTestScreen(taskId: taskId),
                builder: (_) => ChatScreen(
                  taskId: task.id,
                  userId: currentUserId,
                ),
              ),
            );
          },
          icon: Icon(Icons.chat_rounded),
          label: Text('Chat to Poster'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
  }
}