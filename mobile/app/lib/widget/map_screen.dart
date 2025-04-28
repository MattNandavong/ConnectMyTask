import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Map Test')),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-33.8688, 151.2093), // Sydney
          zoom: 12,
        ),
      ),
    );
  }
}
