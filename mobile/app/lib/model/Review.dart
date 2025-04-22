class Review {
  final double rating;
  final String comment;
  final String reviewer;
  final String? photo;
  final DateTime date;

  Review({
    required this.rating,
    required this.comment,
    required this.reviewer,
    required this.date,
    this.photo,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      reviewer: json['reviewer'],
      photo: json['photo'],
      date: DateTime.parse(json['date']),
    );
  }
}
