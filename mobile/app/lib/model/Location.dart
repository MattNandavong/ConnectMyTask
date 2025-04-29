class Location {
  final String type; // 'remote' or 'physical'
  final String? address; // nullable because 'remote' has no address
  final double? lat; // nullable
  final double? lng; // nullable

  Location({
    required this.type,
    this.address,
    this.lat,
    this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      address: json['address'],
      lat: (json['lat'] != null) ? (json['lat'] as num).toDouble() : null,
      lng: (json['lng'] != null) ? (json['lng'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (address != null) 'address': address,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }

  @override
  String toString() {
    if (type == 'remote') return 'Remote Task';
    return '$address';
  }
}
