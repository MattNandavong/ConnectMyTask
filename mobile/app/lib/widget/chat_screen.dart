import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String taskId;
  final String userId;

  ChatScreen({required this.taskId, required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _connectToSocket(); // joins the room via socket.emit('joinTask')
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _loadChatHistory() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3300/api/chat/${widget.taskId}'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        messages.addAll(
          data.map(
            (msg) => {
              'sender': msg['sender'],
              'text': msg['text'],
              'timestamp': msg['timestamp'],
            },
          ),
        );
      });
    }
  }

  void _connectToSocket() {
    print("🔌 Connecting to socket...");
    print("TaskId: ${widget.taskId}");

    socket = IO.io(
      'http://10.0.2.2:3300',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // <- this means we call connect() manually
          .build(),
    );

    // Set up listeners first!
    socket.onConnect((_) {
      print("✅ Connected to socket.io");
      socket.emit('joinTask', {'taskId': widget.taskId});
    });

    socket.onConnectError((data) => print("❌ Connect error: $data"));
    socket.onError((data) => print("❌ Socket error: $data"));
    socket.onDisconnect((_) => print("⚠️ Disconnected from socket"));

    socket.on('receiveMessage', (data) {
      
      print("📨 Received message: $data");
      setState(() {
        messages.add({
          'sender': data['sender'],
          'text': data['text'],
          'timestamp': data['timestamp'],
        });
      });
      _scrollToBottom();
    });

    socket.connect(); //Must come after listeners!
  }

  void _sendMessage() {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  final message = {
    'taskId': widget.taskId,
    'sender': widget.userId,
    'text': text,
  };

  socket.emit('sendMessage', message);
  _controller.clear(); // Only clear input
}

  String _formatTime(String isoTime) {
    final time = DateTime.parse(isoTime);
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("📱 ChatScreen rendering...");
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender']['_id'].toString() == widget.userId.toString();

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[100] : Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(msg['text'], style: TextStyle(color: isMe ? Colors.black: Colors.white),),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _formatTime(msg['timestamp']),
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
