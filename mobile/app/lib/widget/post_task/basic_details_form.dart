// import 'package:flutter/material.dart';
// import 'package:app/utils/voice_service.dart';
// import 'package:app/utils/location_input.dart';

// class BasicDetailsForm extends StatefulWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController titleController;
//   final TextEditingController descController;
//   final TextEditingController budgetController;
//   final TextEditingController locationController;
//   final bool isRemote;
//   final void Function(bool) onRemoteToggle;
//   final void Function(String address, double lat, double lng) onPlaceSelected;
//   final String category;
//   final void Function(String?) onCategoryChanged;

//   const BasicDetailsForm({
//     required this.formKey,
//     required this.titleController,
//     required this.descController,
//     required this.budgetController,
//     required this.locationController,
//     required this.isRemote,
//     required this.onRemoteToggle,
//     required this.onPlaceSelected,
//     required this.category,
//     required this.onCategoryChanged,
//     super.key,
//   });

//   @override
//   State<BasicDetailsForm> createState() => _BasicDetailsFormState();
// }

// class _BasicDetailsFormState extends State<BasicDetailsForm> {
//   late FocusNode _titleFocus;
//   late FocusNode _descFocus;
//   late VoiceService _voiceService;

//   final _categories = [
//     'Cleaning',
//     'Plumbing',
//     'Electrical',
//     'Handyman',
//     'Moving',
//     'Delivery',
//     'Gardening',
//     'Tutoring',
//     'Tech Support',
//     'Other',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _titleFocus = FocusNode();
//     _descFocus = FocusNode();
//     _voiceService = VoiceService();
//   }

//   @override
//   void dispose() {
//     _titleFocus.dispose();
//     _descFocus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: widget.formKey,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: widget.titleController,
//                 focusNode: _titleFocus,
//                 decoration: InputDecoration(
//                   labelText: 'Title',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _voiceService.isListening ? Icons.mic : Icons.mic_none,
//                     ),
//                     onPressed: () {
//                       if (_voiceService.isListening) {
//                         _voiceService.stopListening(() => setState(() {}));
//                       } else {
//                         _titleFocus.unfocus();
//                         _voiceService.startListening(
//                           onResult: (text) => setState(
//                             () => widget.titleController.text += ' $text',
//                           ),
//                           onListeningStarted: () => setState(() {}),
//                           onListeningStopped: () => setState(() {}),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 validator: (val) => val!.isEmpty ? 'Required' : null,
//               ),
//               const SizedBox(height: 12),

//               DropdownButtonFormField(
//                 value: widget.category,
//                 decoration: const InputDecoration(labelText: 'Category'),
//                 items: _categories
//                     .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                     .toList(),
//                 onChanged: widget.onCategoryChanged,
//               ),

//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: widget.descController,
//                 focusNode: _descFocus,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _voiceService.isListening ? Icons.mic : Icons.mic_none,
//                     ),
//                     onPressed: () {
//                       if (_voiceService.isListening) {
//                         _voiceService.stopListening(() => setState(() {}));
//                       } else {
//                         _descFocus.unfocus();
//                         _voiceService.startListening(
//                           onResult: (text) => setState(
//                             () => widget.descController.text += ' $text',
//                           ),
//                           onListeningStarted: () => setState(() {}),
//                           onListeningStopped: () => setState(() {}),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 validator: (val) => val!.isEmpty ? 'Required' : null,
//               ),

//               const SizedBox(height: 12),

//               TextFormField(
//                 controller: widget.budgetController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(labelText: 'Budget (AUD)'),
//                 validator: (val) => val!.isEmpty ? 'Required' : null,
//               ),

//               const SizedBox(height: 12),

//               SwitchListTile(
//                 title: const Text('Remote Task'),
//                 value: widget.isRemote,
//                 onChanged: widget.onRemoteToggle,
//               ),

//               if (!widget.isRemote)
//                 LocationInput(
//                   controller: widget.locationController,
//                   onPlaceSelected: widget.onPlaceSelected,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }