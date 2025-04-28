import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationResult {
  final String address;
  final double latitude;
  final double longitude;

  LocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
