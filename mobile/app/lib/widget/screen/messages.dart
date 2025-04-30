import 'package:app/model/chat_preview.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/utils/chat_service.dart';
import 'package:app/widget/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<ChatPreview> _chatSummaries = [];
  String? _currentUserId;
  bool _isLoading = true;
  late IO.Socket socket;

  //Real device
  final String baseUrl = 'http://192.168.1.101:3300';

  @override
  void initState() {
    super.initState();
    _initialize();
    _loadUserAndChats(); // Load first
    // _connectToSocket();
  }

  Future<void> _initialize() async {
    final chats = await ChatService().getChatSummary();
    final taskIds = chats.map((chat) => chat.taskId).toList();

    setState(() {
      _chatSummaries = List<ChatPreview>.from(chats);
      _isLoading = false;
    });

    _connectToSocket(taskIds);
  }

  void _connectToSocket(List<String> taskIds) {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.onConnect((_) {
      // print('📡 Socket connected');

      // Join all rooms
      for (final taskId in taskIds) {
        socket.emit('joinTask', {'taskId': taskId});
        // print('🏠 Joined task room: $taskId');
      }

      socket.on('receiveMessage', (data) {
        // print('📥 Received new message related to a task room');
        _loadUserAndChats(); // Reload message screen
      });
    });

    socket.connect();
  }

  Future<void> _loadUserAndChats() async {
    final currentUser = await AuthService().getCurrentUser();
    final id = currentUser!.id;
    final chats = await ChatService().getChatSummary(); // API call to backend

    if (!mounted) return;

    setState(() {
      _currentUserId = id;
      _chatSummaries = List<ChatPreview>.from(chats); // important
      _isLoading = false;
    });

    // print('Chat summaries reloaded: ${_chatSummaries.length} chats');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    // SocketService().dispose(); // Clean up socket properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null || _isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body:
          _chatSummaries.isEmpty
              ? Center(child: Text('No chats yet.'))
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _chatSummaries.length,
                itemBuilder: (context, index) {
                  final chat = _chatSummaries[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: Text(
                            chat.partnerName.isNotEmpty
                                ? chat.partnerName[0]
                                : '?',
                            style: TextStyle(
                              // color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          chat.taskTitle,
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          chat.lastMessage!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.figtree(),
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              _formatTimestamp(chat.lastTimestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (chat.unreadCount! > 0) ...[
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${chat.unreadCount}',
                                  style: TextStyle(
                                    // color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ChatScreen(
                                    taskId: chat.taskId,
                                    userId: _currentUserId!,
                                  ),
                            ),
                          ).then((_) async {
                            await _loadUserAndChats();
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
