import 'package:app/model/bid.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart'; // Make sure to import the updated User model

class Task {
  final String id;
  final String title;
  final String description;
  final double budget;
  final DateTime deadline;
  final User user; 
  final List<Bid> bids;
  final String? assignedProvider;
  final String status;
  final String? location;

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
    required this.location,
  });

static Future<Task> fromJsonAsync(Map<String, dynamic> json) async {
  // Handle user being either a String ID or a full user object
  final userField = json['user'];
  late User user;

  if (userField is String) {
    user = await AuthService().getUserProfile(userField);
  } else if (userField is Map<String, dynamic>) {
    user = await AuthService().getUserProfile(userField['_id']); 
  } else {
    throw Exception('Invalid user field in task JSON');
  }

  return Task(
    id: json['_id'],
    title: json['title'],
    description: json['description'],
    budget: (json['budget'] as num).toDouble(),
    deadline: DateTime.parse(json['deadline']),
    user: user,
    bids: (json['bids'] as List).map((b) => Bid.fromJson(b)).toList(),
    assignedProvider: json['assignedProvider'],
    status: json['status'],
    location: json['location']
  );
}


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'budget': budget,
      'deadline': deadline.toIso8601String(),
      'user': user.id, 
      'bids': bids.map((bid) => bid.toJson()).toList(),
      'assignedProvider': assignedProvider,
      'status': status,
    };
  }
}
