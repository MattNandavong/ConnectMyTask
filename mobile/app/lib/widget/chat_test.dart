import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatTestScreen extends StatefulWidget {
  final String taskId;

  ChatTestScreen({required this.taskId});

  @override
  State<ChatTestScreen> createState() => _ChatTestScreenState();
}

class _ChatTestScreenState extends State<ChatTestScreen> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _connectToSocket();
  }

  void _connectToSocket() {
    print("🔌 Connecting to socket...");

    socket = IO.io(
      'http://10.0.2.2:3300',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("✅ Socket connected!");
      print("📨 Joining room: ${widget.taskId}");
      socket.emit('joinTask', {'taskId': widget.taskId});
    });

    socket.onDisconnect((_) {
      print("❌ Socket disconnected");
    });

    socket.onConnectError((data) {
      print("⚠️ Connect error: $data");
    });

    socket.onError((data) {
      print("❌ Error: $data");
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Socket Room")),
      body: Center(
        child: Text(
          "Check logs for socket connection",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
