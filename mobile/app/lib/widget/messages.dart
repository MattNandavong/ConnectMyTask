import 'package:app/model/ChatPreview.dart';
import 'package:app/utils/chat_service.dart';
import 'package:app/widget/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<List<ChatPreview>> _chatSummaries;

  @override
  void initState() {
    super.initState();
    _chatSummaries = ChatService().getChatSummary();
  }

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
      backgroundColor: Color(0xFFF7F7F7), // light background like the image
      body: FutureBuilder<List<ChatPreview>>(
        future: _chatSummaries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading messages'));
          }

          final chats = snapshot.data!;
          if (chats.isEmpty) return Center(child: Text('No chats yet.'));

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        chat.userName[0],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      chat.userName,
                      style: GoogleFonts.figtree(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.figtree(),
                    ),
                    trailing: Text(
                      _formatTimestamp(chat.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            taskId: chat.taskId,
                            userId: chat.userId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
