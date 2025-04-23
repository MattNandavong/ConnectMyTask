class Location {
  final String state;
  final String city;
  final String suburb;

  Location({
    required this.state,
    required this.city,
    required this.suburb,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      suburb: json['suburb'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'city': city,
      'suburb': suburb,
    };
  }

  @override
  String toString() => '$state, $city, $suburb';
}
