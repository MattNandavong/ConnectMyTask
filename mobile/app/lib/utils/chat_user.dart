import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;

  void connect(String taskId, Function(dynamic) onMessageReceived) {
    socket = IO.io(
      'http://localhost:3300', // Use local IP if testing on mobile emulator
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("Connected to Socket.IO");
      socket.emit('joinTask', {'taskId': taskId});
    });

    socket.on('receiveMessage', (data) {
      print("Message received: $data");
      onMessageReceived(data);
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO');
    });
  }

  void sendMessage(String taskId, String senderId, String text) {
    socket.emit('sendMessage', {
      'taskId': taskId,
      'sender': senderId,
      'text': text,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
