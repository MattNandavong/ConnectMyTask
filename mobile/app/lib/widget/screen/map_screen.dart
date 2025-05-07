import 'package:app/model/task.dart';
import 'package:app/widget/browse_task/task_items_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final List<Task> tasks;

  const MapScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    // Filter only tasks with valid lat/lng and physical type
    final physicalTasks =
        tasks.where((task) {
          final location = task.location;
          return location != null &&
              location.type == 'physical' &&
              location.lat != null &&
              location.lng != null;
        }).toList();

    // Convert to Google Map Markers
    Set<Marker> markers =
        physicalTasks.map((task) {
          final LatLng position = LatLng(
            task.location!.lat!,
            task.location!.lng!,
          );
          return Marker(
            markerId: MarkerId(task.id),
            position: position,
            infoWindow: InfoWindow(
              title: task.title,
              onTap: () => _showTaskPreview(context, task),
            ),
          );
        }).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks on Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              physicalTasks.isNotEmpty
                  ? LatLng(
                    physicalTasks[0].location!.lat!,
                    physicalTasks[0].location!.lng!,
                  )
                  : const LatLng(0, 0),
          zoom: 12,
        ),
        markers: markers,
      ),
    );
  }

  void _showTaskPreview(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: TaskCard(context: context, task: task),
      ),
    );
  }
}
