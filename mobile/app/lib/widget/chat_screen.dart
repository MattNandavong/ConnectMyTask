import 'package:flutter/material.dart';
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
    // Simulated delay for loading fake messages
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        messages.addAll([
          {
            'sender': 'user123',
            'text': 'Hi, is this task still available?',
            'timestamp':
                DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
          },
          {
            'sender': widget.userId,
            'text': 'Yes! Feel free to make an offer.',
            'timestamp':
                DateTime.now().subtract(Duration(minutes: 3)).toIso8601String(),
          },
        ]);
      });
    });

    // Comment this out until backend is live
    // _connectToSocket();
  }

  void _connectToSocket() {
    socket = IO.io(
      'http://localhost:3300',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("🔌 Connected to socket.io");
      socket.emit('joinTask', {'taskId': widget.taskId});
    });

    socket.on('receiveMessage', (data) {
      setState(() {
        messages.add({
          'sender': data['sender'],
          'text': data['text'],
          'timestamp': data['timestamp'],
        });
      });
    });

    socket.onDisconnect((_) => print('❌ Disconnected from socket'));
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'sender': widget.userId,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _controller.clear();
    });

    // Comment this out until backend is live
    // socket.emit('sendMessage', message);
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
                final isMe = msg['sender'] == widget.userId;
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
                          color: isMe ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(msg['text']),
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
