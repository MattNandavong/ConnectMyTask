// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class buildPreview extends StatelessWidget {
//   final TextEditingController title;
//   final TextEditingController description;
//   final String category;
//   final TextEditingController budget;
//   final DateTime? deadline;
//   final TimeOfDay? deadlineTime;
//   final bool isRemote;
//   final String? address;
//   final double? lat;
//   final double? lng;
//   final List<Map<String, dynamic>> images;
//   final VoidCallback onSubmit;

//   const buildPreview({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.budget,
//     required this.deadline,
//     required this.deadlineTime,
//     required this.isRemote,
//     required this.address,
//     required this.lat,
//     required this.lng,
//     required this.images,
//     required this.onSubmit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: EdgeInsets.all(16),
//       children: [
//         Text(
//           "Review Your Task",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 20),

//         _buildPreviewTile(Icons.title, "Title", title.text),
//         _buildPreviewTile(Icons.category, "Category", category),
//         _buildPreviewTile(
//           Icons.description,
//           "Description",
//           description.text,
//         ),
//         _buildPreviewTile(
//           Icons.attach_money,
//           "Budget",
//           "\$${budget.text}",
//         ),

//         if (deadline != null)
//           _buildPreviewTile(
//             Icons.schedule,
//             "Deadline",
//             "${_formatter.format(deadline!)} ${deadlineTime?.format(context) ?? ''}",
//           ),

//         _buildPreviewTile(
//           Icons.location_on,
//           "Location",
//           isRemote ? "Remote" : (selectedAddress ?? "Not selected"),
//         ),

//         SizedBox(height: 20),

//         if (!isRemote && selectedLat != null && selectedLng != null)
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: SizedBox(
//               height: 200,
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(_selectedLat!, _selectedLng!),
//                   zoom: 15,
//                 ),
//                 markers: {
//                   Marker(
//                     markerId: MarkerId('selected-location'),
//                     position: LatLng(_selectedLat!, _selectedLng!),
//                   ),
//                 },
//                 zoomControlsEnabled: false,
//                 liteModeEnabled: true,
//               ),
//             ),
//           ),

//         SizedBox(height: 20),

//         Text(
//           "Images",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         SizedBox(height: 8),

//         if (_imagesWithCaptions.isEmpty)
//           Center(
//             child: Text(
//               "No images uploaded",
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//         if (_imagesWithCaptions.isNotEmpty)
//           SizedBox(
//             height: 100,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: _imagesWithCaptions.length,
//               separatorBuilder: (_, __) => SizedBox(width: 10),
//               itemBuilder: (context, index) {
//                 final img = _imagesWithCaptions[index];
//                 return ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.file(
//                     img['file'],
//                     width: 100,
//                     height: 100,
//                     fit: BoxFit.cover,
//                   ),
//                 );
//               },
//             ),
//           ),

//         SizedBox(height: 30),

//         ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             minimumSize: Size(double.infinity, 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           icon: Icon(Icons.send),
//           label: Text('Confirm & Submit', style: TextStyle(fontSize: 18)),
//           onPressed: _submitTask,
//         ),
//       ],
//     );
//   }
// }

// Widget _buildPreviewTile(IconData icon, String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: Colors.teal),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 value.isNotEmpty ? value : '-',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
