class ChatPreview {
  final String taskId;
  final String userId; // recipient
  final String userName;
  final String lastMessage;
  final DateTime timestamp;

  ChatPreview({
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      taskId: json['taskId'],
      userId: json['userId'],
      userName: json['userName'],
      lastMessage: json['lastMessage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
