class ChatPreview {
  final String taskId;
  final String taskTitle;
  final String partnerName;
  final String? partnerProfilePhoto;
  final String? lastMessage;
  final String? lastImage;
  final DateTime lastTimestamp;
  final int? unreadCount;

  ChatPreview({
    required this.taskId,
    required this.taskTitle,
    required this.partnerName,
    this.partnerProfilePhoto,
    this.lastMessage,
    this.lastImage,
    required this.lastTimestamp,
    this.unreadCount
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      taskId: json['taskId'],
      taskTitle: json['taskTitle'],
      partnerName: json['partnerName'],
      partnerProfilePhoto: json['partnerProfilePhoto'],
      lastMessage: json['lastMessage'],
      lastImage: json['lastImage'],
      lastTimestamp: DateTime.parse(json['lastTimestamp']),
      unreadCount: json['unreadCount']
    );
  }
}
