import 'dart:io';
import 'package:app/utils/location_input.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/utils/voice_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:easy_localization/easy_localization.dart';

late VoiceService _voiceService;

class PostTask extends StatefulWidget {
  const PostTask({super.key});
  @override
  State<PostTask> createState() => _PostTaskState();
}

class _PostTaskState extends State<PostTask> {
  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final DateFormat _formatter = DateFormat.yMMMMd();

  late FocusNode _titleFocus;
  late FocusNode _descFocus;
  late stt.SpeechToText _speech;

  bool _isListening = false;
  bool _isRemote = true;
  int _currentStep = 0;
  DateTime? _deadline;
  TimeOfDay? _deadlineTime;
  String _category = 'Cleaning';
  bool _isFlexible = false;
  String _deadlineType = 'Flexible'; // or 'Flexible'
  bool _deadlineError = false;

  List<Map<String, dynamic>> _imagesWithCaptions = [];

  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;

  final _categories = [
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Handyman',
    'Moving',
    'Delivery',
    'Gardening',
    'Tutoring',
    'Tech Support',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _titleFocus = FocusNode();
    _descFocus = FocusNode();
    _voiceService = VoiceService();
    _isFlexible = false;
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  void _openLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: LocationInput(
                onPlaceSelected: (address, lat, lng) {
                  setState(() {
                    _locationController.text = address;
                    _selectedAddress = address;
                    _selectedLat = lat;
                    _selectedLng = lng;
                  });
                },
              ),
            ),
          ),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDate: _deadline ?? DateTime.now(),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      setState(() {
        _deadline = date;
        _deadlineTime = time ?? TimeOfDay(hour: 23, minute: 59);
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 75);
    if (files != null) {
      setState(() {
        _imagesWithCaptions.addAll(
          files.map((e) => {'file': File(e.path), 'caption': ''}),
        );
      });
    }
  }

  Future<void> _submitTask() async {
    if (_formKeys[_currentStep].currentState?.validate() ?? true) {
      if (!_isRemote &&
          (_selectedAddress == null ||
              _selectedLat == null ||
              _selectedLng == null)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please select location')));
        return;
      }
      try {
        DateTime? deadlineDateTime;
        if(_deadline != null){
          deadlineDateTime = DateTime(
          _deadline!.year,
          _deadline!.month,
          _deadline!.day,
          _deadlineTime?.hour ?? 23,
          _deadlineTime?.minute ?? 59,
        );
        }
          
        await TaskService().createTask(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          budget: double.tryParse(_budgetController.text.trim()) ?? 0,
          deadline: deadlineDateTime?.toIso8601String(),
          category: _category,
          location:
              _isRemote
                  ? {'type': 'remote'}
                  : {
                    'type': 'physical',
                    'address': _selectedAddress ?? '',
                    'lat': _selectedLat ?? 0.0,
                    'lng': _selectedLng ?? 0.0,
                  },
          images:
              _imagesWithCaptions.map((img) => img['file'] as File).toList(),
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task Submitted')));
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit task: $e')));
      }
    }
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _titleController.clear();
      _descController.clear();
      _budgetController.clear();
      _locationController.clear();
      _imagesWithCaptions.clear();
      _isRemote = true;
      _selectedAddress = null;
      _selectedLat = null;
      _selectedLng = null;
      _deadline = null;
      _deadlineTime = null;
    });
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildBasicDetailsForm();
      case 1:
        return _buildImagesUploadForm();
      case 2:
        return _buildPreview();
      default:
        return SizedBox();
    }
  }

  Widget _buildBasicDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'postTask'.tr().toUpperCase(),
                style: GoogleFonts.oswald(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Expanded(
            child: Card(
              child: Container(
                // padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  // border: Border.all(),
                  // color: Colors.white,
                ),
                child: Form(
                  key: _formKeys[0],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              focusNode: _titleFocus,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _voiceService.isListening
                                        ? Icons.mic
                                        : Icons.mic_none,
                                  ),
                                  onPressed: () {
                                    if (_voiceService.isListening) {
                                      _voiceService.stopListening(
                                        () => setState(() {}),
                                      );
                                    } else {
                                      _titleFocus.unfocus();
                                      _voiceService.startListening(
                                        onResult:
                                            (text) => setState(
                                              () =>
                                                  _titleController.text +=
                                                      ' $text',
                                            ),
                                        onListeningStarted:
                                            () => setState(() {}),
                                        onListeningStopped:
                                            () => setState(() {}),
                                      );
                                    }
                                  },
                                ),
                              ),
                              validator:
                                  (val) => val!.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 12),
                            DropdownButtonFormField(
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              value: _category,
                              decoration: InputDecoration(
                                labelText: 'Category',
                              ),
                              items:
                                  _categories
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setState(() => _category = val!),
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _descController,
                              focusNode: _descFocus,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _voiceService.isListening
                                        ? Icons.mic
                                        : Icons.mic_none,
                                  ),
                                  onPressed: () {
                                    if (_voiceService.isListening) {
                                      _voiceService.stopListening(
                                        () => setState(() {}),
                                      );
                                    } else {
                                      _descFocus.unfocus();
                                      _voiceService.startListening(
                                        onResult:
                                            (text) => setState(
                                              () =>
                                                  _descController.text +=
                                                      ' $text',
                                            ),
                                        onListeningStarted:
                                            () => setState(() {}),
                                        onListeningStopped:
                                            () => setState(() {}),
                                      );
                                    }
                                  },
                                ),
                              ),
                              validator:
                                  (val) => val!.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Budget (AUD)',
                              ),
                              validator:
                                  (val) => val!.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _deadlineType,
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              decoration: InputDecoration(
                                labelText: 'Deadline',
                                border: OutlineInputBorder(),
                                filled: true,
                                // fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              items:
                                  ['I am not flexible', 'Flexible']
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _deadlineType = val;
                                  });
                                }
                              },
                            ),

                            if (_deadlineType != 'Flexible')
                              ListTile(
                                title: Container(
                                  // padding: EdgeInsets.all(10),
                                  width: 100,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          _deadlineError
                                              ? Theme.of(context).colorScheme.error
                                              : Colors.transparent, 
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _deadline != null
                                          ? '${_formatter.format(_deadline!)} ${_deadlineTime?.format(context) ?? ''}'
                                          : 'Select Deadline',
                                      style: TextStyle(
                                        color:
                                          _deadlineError
                                              ? Theme.of(context).colorScheme.error
                                              : Colors.transparent, 
                                      ),
                                    ),
                                  ),
                                ),
                                trailing: Icon(Icons.calendar_today),
                                onTap: _pickDeadline,
                              ),
                            SwitchListTile(
                              title: Text(
                                'Remote Task',
                                style: GoogleFonts.figtree(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: _isRemote,
                              onChanged:
                                  (val) => setState(() => _isRemote = val),
                            ),
                            if (!_isRemote) ...[
                              GestureDetector(
                                onTap: () => _openLocationModal(),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: _locationController,
                                    decoration: const InputDecoration(
                                      labelText: 'Location',
                                      hintText: 'Select location',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) {
                                      if (!_isRemote &&
                                          (val == null || val.isEmpty)) {
                                        return 'Please select a location';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesUploadForm() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Upload Image'.toUpperCase(),
                style: GoogleFonts.oswald(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Expanded(
            child: Card(
              child: Container(
                // padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  // border: Border.all(),
                  // color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            _imagesWithCaptions.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_library_outlined,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'No Images Uploaded',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ReorderableListView.builder(
                                  itemCount: _imagesWithCaptions.length,
                                  onReorder: (oldIndex, newIndex) {
                                    setState(() {
                                      if (newIndex > oldIndex) newIndex--;
                                      final item = _imagesWithCaptions.removeAt(
                                        oldIndex,
                                      );
                                      _imagesWithCaptions.insert(
                                        newIndex,
                                        item,
                                      );
                                    });
                                  },

                                  itemBuilder: (context, index) {
                                    final image = _imagesWithCaptions[index];
                                    return ListTile(
                                      key: ValueKey(index),
                                      leading: Image.file(
                                        image['file'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => setState(
                                              () => _imagesWithCaptions
                                                  .removeAt(index),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.photo_library),
                        label: Text('Upload Images'),
                        onPressed: _pickImages,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Task Preview'.toUpperCase(),
                style: GoogleFonts.oswald(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Expanded(
            child: Card(
              child: Container(
                // padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  // border: Border.all(),
                  // color: Colors.white,
                ),
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    _buildPreviewTile(
                      Icons.title,
                      "Title",
                      _titleController.text,
                    ),
                    _buildPreviewTile(Icons.category, "Category", _category),
                    _buildPreviewTile(
                      Icons.description,
                      "Description",
                      _descController.text,
                    ),
                    _buildPreviewTile(
                      Icons.attach_money,
                      "Budget",
                      "\$${_budgetController.text}",
                    ),

                    if (_deadline != null)
                      _buildPreviewTile(
                        Icons.schedule,
                        "Deadline",
                        "${_formatter.format(_deadline!)} ${_deadlineTime?.format(context) ?? ''}",
                      ),

                    _buildPreviewTile(
                      Icons.location_on,
                      "Location",
                      _isRemote
                          ? "Remote"
                          : (_selectedAddress ?? "Not selected"),
                    ),

                    SizedBox(height: 20),

                    if (!_isRemote &&
                        _selectedLat != null &&
                        _selectedLng != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(_selectedLat!, _selectedLng!),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId('selected-location'),
                                position: LatLng(_selectedLat!, _selectedLng!),
                              ),
                            },
                            zoomControlsEnabled: false,
                            liteModeEnabled: true,
                          ),
                        ),
                      ),

                    SizedBox(height: 20),

                    Text(
                      "Images",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),

                    if (_imagesWithCaptions.isEmpty)
                      Center(
                        child: Text(
                          "No images uploaded",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    if (_imagesWithCaptions.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imagesWithCaptions.length,
                          separatorBuilder: (_, __) => SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final img = _imagesWithCaptions[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                img['file'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),

                    SizedBox(height: 30),

                    FilledButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.send),
                      label: Text(
                        'Confirm & Submit',
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: _submitTask,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            color: Colors.teal,
          ),

          Expanded(child: _buildStepContent(_currentStep)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: Text('Back'),
                  ),
                if (_currentStep < 2)
                  ElevatedButton(
                    onPressed: () {
                      bool validForm =
                          _formKeys[_currentStep].currentState?.validate() ??
                          true;
                      if (!validForm) return;
                      // Validate location if not remote
                      if (_currentStep == 0 && !_isRemote) {
                        if (_selectedAddress == null ||
                            _selectedAddress!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a valid location'),
                            ),
                          );
                          return;
                        }
                      }

                      // Validate deadline if not flexible
                      if (_deadlineType.toLowerCase() != 'flexible' &&
                          _deadline == null) {
                        setState(() {
                          _deadlineError = true; // Set error flag
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a deadline')),
                        );
                        return;
                      } else {
                        setState(() {
                          _deadlineError = false;
                        });
                      }

                      setState(() => _currentStep++);
                    },

                    child: Text('Next'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
