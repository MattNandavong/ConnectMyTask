import 'package:app/model/bid.dart';
import 'package:app/model/user.dart'; // Make sure to import the updated User model

class Task {
  final String id;
  final String title;
  final String description;
  final double budget;
  final DateTime deadline;
  final User user; // ✅ Uses full User model
  final List<Bid> bids;
  final String? assignedProvider;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.user,
    required this.bids,
    required this.assignedProvider,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      budget: (json['budget'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline']),
      user: User.fromJson(json['user']), // ✅ Create full User
      bids: (json['bids'] as List).map((bid) => Bid.fromJson(bid)).toList(),
      assignedProvider: json['assignedProvider'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'budget': budget,
      'deadline': deadline.toIso8601String(),
      'user': user.toJson(), // ✅ Store User
      'bids': bids.map((bid) => bid.toJson()).toList(),
      'assignedProvider': assignedProvider,
      'status': status,
    };
  }
}
