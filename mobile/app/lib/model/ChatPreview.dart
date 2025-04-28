class ChatPreview {
  final String taskId;
  final String partnerName;
  final String? partnerProfilePhoto;
  final String? lastMessage;
  final String? lastImage;
  final DateTime lastTimestamp;

  ChatPreview({
    required this.taskId,
    required this.partnerName,
    this.partnerProfilePhoto,
    this.lastMessage,
    this.lastImage,
    required this.lastTimestamp,
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      taskId: json['taskId'],
      partnerName: json['partnerName'],
      partnerProfilePhoto: json['partnerProfilePhoto'],
      lastMessage: json['lastMessage'],
      lastImage: json['lastImage'],
      lastTimestamp: DateTime.parse(json['lastTimestamp']),
    );
  }
}
