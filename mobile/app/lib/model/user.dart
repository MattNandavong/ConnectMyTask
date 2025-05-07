import 'dart:math';
import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? role;
  final String? profilePhoto;
  final Map<String, dynamic>? location;
  final List<String> skills;
  final bool isVerified;
  final double averageRating;
  final int totalReviews;
  final int completedTasks;
  final int recommendations;
  final String? rank;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.profilePhoto,
    this.location,
    this.skills = const [],
    this.isVerified = false,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.completedTasks = 0,
    this.recommendations = 0,
    this.rank,
  });

  factory User.fromJson(Map<String, dynamic> json) {
  double parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0; // Fallback if null or invalid
  }

  int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  return User(
    id: json['_id'] ?? json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    profilePhoto: json['profilePhoto'],
    location: json['location'] != null ? Map<String, dynamic>.from(json['location']) : null,
    skills: List<String>.from(json['skills'] ?? []),
    isVerified: json['isVerified'] ?? false,
    averageRating: parseDouble(json['averageRating']),
    totalReviews: parseInt(json['totalReviews']),
    completedTasks: parseInt(json['completedTasks']),
    recommendations: parseInt(json['recommendations']),
    rank: json['rank'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'profilePhoto': profilePhoto,
      'location': location,
      'skills': skills,
      'isVerified': isVerified,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'completedTasks': completedTasks,
      'recommendations': recommendations,
      'rank': rank,
    };
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 2).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color get avatarColor {
    final seed = id.hashCode;
    final random = Random(seed);
    return Color.fromARGB(
      255,
      150 + random.nextInt(100),
      100 + random.nextInt(120),
      150 + random.nextInt(100),
    );
  }

  Widget buildAvatar({double radius = 24}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      backgroundImage:
          profilePhoto != null && profilePhoto!.isNotEmpty ? NetworkImage(profilePhoto!) : null,
      child: profilePhoto == null || profilePhoto!.isEmpty
          ? Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.7,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
