class LocalNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;

  final String? taskId; // nullable

  LocalNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    this.taskId,
    this.read = false,
  });

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      taskId: json['taskId'], // nullable
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'taskId': taskId,
    'read': read,
  };
}
