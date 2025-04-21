import 'package:app/model/chat.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/chat_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final List<ChatPreview> dummyChats = [
    ChatPreview(
      userId: 'user123',
      userName: 'John Smith',
      lastMessage: 'Looking forward to working on your task!',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    ChatPreview(
      userId: 'user456',
      userName: 'Emma Brown',
      lastMessage: 'Please send the full address again.',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
    ),
    ChatPreview(
      userId: 'user789',
      userName: 'Michael Lee',
      lastMessage: 'Task completed. Let me know your feedback!',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      // appBar: AppBar(title: Text('Messages')),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: dummyChats.length,
        itemBuilder: (context, index) {
          final chat = dummyChats[index];
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(28, 0, 0, 0),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  textColor: Colors.black,
                  leading: CircleAvatar(child: Text(chat.userName[0])),
                  title: Text(
                    chat.userName,
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTimestamp(chat.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    // Navigate to ChatScreen
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(userId: chat.userId)));
                  },
                ),
              ),
              // Divider(thickness: 1, color: Color.fromARGB(64, 0, 126, 61),),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
