import 'package:app/model/user.dart';

class Review {
  final double rating;
  final String comment;
  final User reviewer;

  Review({
    required this.rating,
    required this.comment,
    required this.reviewer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      reviewer: User.fromJson(json['reviewer']),
    );
  }

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
        'reviewer': reviewer.toJson(),
      };
}
