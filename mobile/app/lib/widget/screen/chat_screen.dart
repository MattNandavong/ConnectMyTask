import 'dart:convert';
import 'dart:io';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';
import 'package:app/utils/task_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  User? partner;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _connectToSocket();
    markMessagesAsRead();
    _loadChatPartner();
  }

  //Real device
  final String baseUrl = 'http://192.168.1.101:3300';

  Future<void> markMessagesAsRead() async {
    final token = await AuthService().getToken();
    await http.put(
      Uri.parse('http://192.168.1.101:3300/api/messages/${widget.taskId}/read'),
      headers: {'Authorization': '$token', 'Content-Type': 'application/json'},
    );
  }

  Future<void> _loadChatHistory() async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      final token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse('http://192.168.1.101:3300/api/messages/${widget.taskId}'),
        headers: {
          'Authorization': "$token",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          messages.addAll(data.cast<Map<String, dynamic>>());
        });
        _scrollToBottom();
      } else {
        print('❌ Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error loading chat history: $e");
    }
  }

  void _connectToSocket() {
    socket = IO.io(
      '$baseUrl',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.onConnect((_) => socket.emit('joinTask', {'taskId': widget.taskId}));
    socket.on('receiveMessage', (data) {
      print("📥 Received message from socket:");
      print(data);
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

  Future<void> _loadChatPartner() async {
    final task = await TaskService().getTask(widget.taskId);
    final currentUserId = widget.userId;

    String partnerId;

    if (task.user.id == currentUserId) {
      partnerId = task.assignedProvider?.id ?? '';
    } else {
      partnerId = task.user.id;
    }

    if (partnerId.isEmpty) return;

    final partnerData = await AuthService().getUserProfile(partnerId);

    setState(() {
      partner = partnerData;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    // final now = DateTime.now().toIso8601String();
    final task = await TaskService().getTask(widget.taskId);

    if (text.isNotEmpty) {
      // Send text message via HTTP POST (not socket.emit directly)
      try {
        // Correct receiver logic based on who is sending
        final currentUserId = widget.userId;
        final receiverId =
            (currentUserId == task.user.id)
                ? task.assignedProvider?.id
                : task.user.id;

        final token = await AuthService().getToken();
        final response = await http.post(
          Uri.parse('http://192.168.1.101:3300/api/messages/${widget.taskId}'),
          headers: {
            'Authorization': '$token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'text': text, 'receiverId': receiverId}),
        );

        if (response.statusCode == 201) {
          final savedMessage = jsonDecode(response.body);
          print('📨 Text message saved: $savedMessage');
          // No need to manually emit socket now — server already emits after save
        } else {
          print('❌ Failed to send text message: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error sending text message: $e');
      }

      _controller.clear();
    }

    // Upload pending images
    for (var img in _pendingImages) {
      try {
        final currentUserId = widget.userId;
        final receiverId =
            (currentUserId == task.user.id)
                ? task.assignedProvider?.id
                : task.user.id;

        final token = await AuthService().getToken();
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.1.101:3300/api/messages/${widget.taskId}'),
        );

        request.headers['Authorization'] = '$token';
        request.fields['caption'] = img['caption'] ?? '';
        request.fields['receiverId'] = receiverId ?? '';
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            img['file'].path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        final streamedResponse = await request.send();
        final resBody = await streamedResponse.stream.bytesToString();

        if (streamedResponse.statusCode == 201) {
          final savedImageMessage = jsonDecode(resBody);
          print('🖼️ Image uploaded and saved: $savedImageMessage');
          // Again, server will emit receiveMessage automatically
        } else {
          print('❌ Failed to upload image: ${streamedResponse.statusCode}');
        }
      } catch (e) {
        print('❌ Error uploading image: $e');
      }
    }

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        // backgroundColor: Color(0xFFF5F7FA),
        elevation: 1,
        leading: BackButton(),
        title:
            partner == null
                ? Text('Loading...')
                : Row(
                  children: [
                    partner!.buildAvatar(radius: 18),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner!.name,
                          style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
      body: Column(
        children: [
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
                          color: isMe ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.inverseSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (msg['image'] != null &&
                                msg['image'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Builder(
                                  builder: (context) {
                                    print(
                                      '🖼️ Trying to load image: ${msg['image']}',
                                    ); // <== Add this
                                    return Image.network(
                                      msg['image'],
                                      width: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        print('❌ Image load failed: $error');
                                        return Text('Failed to load image');
                                      },
                                    );
                                  },
                                ),
                              ),

                            if ((msg['text'] ?? '').trim().isNotEmpty &&
                                msg['text'] != '[Image]')
                              Text(
                                msg['text'],
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
                      icon: Icon(Icons.image, color: Theme.of(context).colorScheme.secondary,),
                      onPressed: _selectImages,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          // filled: true,
                          // fillColor: Theme.of(context).colorScheme.inverseSurface,
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
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: IconButton(
                        icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onInverseSurface),
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
