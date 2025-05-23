import 'package:app/model/location.dart';
import 'package:app/model/bid.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/auth_service.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final double budget;
  final DateTime? deadline;
  final String status;
  final String category;
  final User user;
  final List<Bid> bids;
  final User? assignedProvider;
  final Location? location;
  final List<String> images;
  final int? reviewRating;
  final String? reviewComment;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    this.deadline,
    required this.status,
    required this.category,
    required this.user,
    required this.bids,
    required this.assignedProvider,
    required this.location,
    required this.images,
    this.reviewRating,
    this.reviewComment,
    required this.createdAt,
  });

  static Future<Task> fromJsonAsync(Map<String, dynamic> json) async {
    double _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return null;
  }

    final userField = json['user']['_id'];
    final providerField = json['assignedProvider'];

    final User user = userField is String
        ? await AuthService().getUserProfile(userField)
        : User.fromJson(userField);

    User? assignedProvider;
    if (providerField is String) {
      assignedProvider = await AuthService().getUserProfile(providerField);
    } else if (providerField is Map<String, dynamic>) {
      assignedProvider = User.fromJson(providerField);
    }

    final locationData = json['location'];
    Location? parsedLocation;
    if (locationData is Map<String, dynamic>) {
      parsedLocation = Location.fromJson(locationData);
    }

    final reviewData = json['review'];
    final int? rating = _parseInt(reviewData != null ? reviewData['rating'] : null);
    final String? comment = reviewData != null ? reviewData['comment'] as String? : null;

    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      budget: _parseDouble(json['budget']),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      status: json['status'],
      category: json['category'],
      user: user,
      bids: (json['bids'] as List).map((b) => Bid.fromJson(b)).toList(),
      assignedProvider: assignedProvider,
      location: parsedLocation,
      images: List<String>.from(json['images'] ?? []),
      reviewRating: rating,
      reviewComment: comment,
      createdAt: DateTime.parse(json['createdAt'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'budget': budget,
      'deadline': deadline?.toIso8601String(),
      'status': status,
      'category': category,
      'user': user.id,
      'bids': bids.map((b) => b.toJson()).toList(),
      'assignedProvider': assignedProvider?.id,
      'location': location?.toJson(),
      'images': images,
      'review': {
        'rating': reviewRating,
        'comment': reviewComment,
      },
      'createdAt': createdAt,

    };
  }
}
