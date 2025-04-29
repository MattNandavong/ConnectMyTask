class Bid {
  final String id;
  final String provider; // Just the provider ID
  final double price;
  final String? comment;
  final int estimatedTime;
  final DateTime date;

  Bid({
    required this.id,
    required this.provider,
    required this.price,
    this.comment,
    required this.estimatedTime,
    required this.date,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['_id'],
      provider: json['provider'],
      comment: json['comment'] ?? "No comment",
      price: (json['price'] as num).toDouble(),
      estimatedTime: int.tryParse(json['estimatedTime'].toString()) ?? 0,
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'provider': provider,
      'price': price,
      'comment': comment,
      'estimatedTime': estimatedTime,
      'date': date.toIso8601String(),
    };
  }

  // Bid copyWith({
  //   String? id,
  //   String? provider,
  //   double? price,
  //   int? estimatedTime,
  //   DateTime? date,
  // }) {
  //   return Bid(
  //     id: id ?? this.id,
  //     provider: provider ?? this.provider,
  //     price: price ?? this.price,
  //     estimatedTime: estimatedTime ?? this.estimatedTime,
  //     date: date ?? this.date,
  //   );
  // }
}
