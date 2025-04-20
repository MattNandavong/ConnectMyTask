import 'dart:math';
import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;      
  final double? rating;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.rating,
  });

factory User.fromJson(Map<String, dynamic> json) {
  final rawId = json['_id'] ?? json['id'];
  if (rawId == null) throw Exception('User ID is missing in JSON');

  return User(
    id: rawId,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? '',
    rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
  );
}


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,  
      if (rating != null) 'rating': rating,
    };
  }

  @override
  String toString() {
    return '$name <$email> ($role)';
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, min(2, parts[0].length)).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color get avatarColor {
    final seed = id.hashCode;
    final random = Random(seed);
    return Color.fromARGB(
      255,
      150 + random.nextInt(100),
      100 + random.nextInt(130),
      150 + random.nextInt(100),
    );
  }

  Widget buildAvatar({double radius = 20}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
          color: Colors.white,
        ),
      ),
    );
  }
}
