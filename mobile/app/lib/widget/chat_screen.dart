// Required imports
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  final List<Map<String, dynamic>> _pendingImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _connectToSocket();
  }

  Future<void> _loadChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3300/api/chat/${widget.taskId}'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          messages.addAll(data.cast<Map<String, dynamic>>());
        });
      }
    } catch (e) {
      print("❌ Error loading chat: $e");
    }
  }

  void _connectToSocket() {
    socket = IO.io(
      'http://10.0.2.2:3300',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.onConnect((_) => socket.emit('joinTask', {'taskId': widget.taskId}));
    socket.on('receiveMessage', (data) {
      setState(() => messages.add(data));
      _scrollToBottom();
    });
    socket.connect();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _selectImages() async {
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 75);
    if (pickedFiles == null) return;

    final tempDir = await getTemporaryDirectory();

    for (var xfile in pickedFiles) {
      final targetPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        xfile.path,
        targetPath,
        quality: 70,
      );
      if (result != null) {
        setState(() {
          _pendingImages.add({'file': File(result.path), 'caption': ''});
        });
      }
    }
  }

  Future<void> _sendMessage() async {
  final text = _controller.text.trim();
  final now = DateTime.now().toIso8601String();

  // Emit text message
  if (text.isNotEmpty) {
    final msg = {
      'taskId': widget.taskId,
      'sender': {'_id': widget.userId},
      'text': text,
      'timestamp': now,
    };
    socket.emit('sendMessage', msg);
    _controller.clear();
    // setState(() => messages.add(msg));
  }

  // Simulate local image sending without backend
  // for (var img in _pendingImages) {
  //   final simulatedMsg = {
  //     'sender': {'_id': widget.userId},
  //     'text': img['caption'] ?? '[Image]',
  //     'image': img['file'].path, // local file path
  //     'timestamp': DateTime.now().toIso8601String(),
  //   };
  //   setState(() => messages.add(simulatedMsg));
  // }

  setState(() => _pendingImages.clear());
  _scrollToBottom();
}



  String _formatTime(String iso) {
    final time = DateTime.parse(iso);
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F7FA),
        elevation: 1,
        leading: BackButton(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat Partner',
                  style: GoogleFonts.figtree(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 📩 Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final senderId =
                    msg['sender'] is Map ? msg['sender']['_id'] : msg['sender'];
                final isMe = senderId == widget.userId;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF007AFF) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (msg['image'] != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Image.network(
                                  msg['image'],
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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

          // 📝 Message input + image preview
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              children: [
                if (_pendingImages.isNotEmpty)
                  Container(
                    height: 110,
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pendingImages.length,
                      itemBuilder: (context, index) {
                        final item = _pendingImages[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      item['file'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(
                                            () =>
                                                _pendingImages.removeAt(index),
                                          ),
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.black54,
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              SizedBox(
                                width: 80,
                                height: 30,
                                child: TextField(
                                  onChanged:
                                      (val) =>
                                          _pendingImages[index]['caption'] =
                                              val,
                                  style: TextStyle(fontSize: 10),
                                  decoration: InputDecoration(
                                    hintText: 'Caption',
                                    contentPadding: EdgeInsets.all(4),
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: _selectImages,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Color(0xFF007AFF),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
