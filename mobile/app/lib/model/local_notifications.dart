class LocalNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;

  LocalNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
  });

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'read': read,
      };
}
