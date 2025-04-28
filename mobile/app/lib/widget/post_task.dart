import 'dart:convert';
import 'dart:io';
import 'package:app/utils/task_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:app/utils/voice_service.dart';

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
  String _activeField = ''; // To know which input field to fill

  String _category = 'Cleaning';
  double _budget = 0.0;
  bool _isRemote = true;
  // String _selectedState = 'VIC';
  String? _city;
  DateTime? _deadline;
  TimeOfDay? _deadlineTime;
  int _currentStep = 0;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedSuburb;

  List<Map<String, dynamic>> _imagesWithCaptions = [];

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

  final Map<String, Map<String, List<String>>> _locationData = {
    "New South Wales": {
      "Sydney": ["Parramatta", "Bondi", "Manly", "Chatswood"],
      "Newcastle": ["Cessnock", "Maitland", "Lake Macquarie"],
    },
    "Victoria": {
      "Melbourne": ["Carlton", "Fitzroy", "Brunswick"],
      "Geelong": ["Lara", "Torquay"],
    },
    "Queensland": {
      "Brisbane": ["Fortitude Valley", "South Bank", "Paddington"],
      "Gold Coast": ["Surfers Paradise", "Broadbeach"],
    },
  };

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

  void _submitTask() async {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Confirm Submit'),
            content: Text('Do you want to post this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // close dialog

                  try {
                    final deadlineDateTime = DateTime(
                      _deadline!.year,
                      _deadline!.month,
                      _deadline!.day,
                      _deadlineTime?.hour ?? 23,
                      _deadlineTime?.minute ?? 59,
                    );
                    if (!_isRemote &&
                        (_selectedState == null ||
                            _selectedCity == null ||
                            _selectedSuburb == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select full location')),
                      );
                      return;
                    }
                    // print( "${_titleController.text.trim()},${_descController.text.trim()},${double.tryParse(_budgetController.text.trim()) ?? 0},${deadlineDateTime.toIso8601String()},$_category,${'location.state':_isRemote ? 'Remote' : _selectedState!,'location.city': _isRemote ? 'Remote' : _selectedCity!,'location.suburb':_isRemote ? 'Remote' : _selectedSuburb!,}}",);

                    await TaskService().createTask(
                      title: _titleController.text.trim(),
                      description: _descController.text.trim(),
                      budget:
                          double.tryParse(_budgetController.text.trim()) ?? 0,
                      deadline: deadlineDateTime.toIso8601String(),
                      category: _category,

                      location: {
                        'location.state':
                            _isRemote ? 'Remote' : _selectedState!,
                        'location.city': _isRemote ? 'Remote' : _selectedCity!,
                        'location.suburb':
                            _isRemote ? 'Remote' : _selectedSuburb!,
                      },

                      images:
                          _imagesWithCaptions
                              .map((img) => img['file'] as File)
                              .toList(),
                    );

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Task Submitted')));

                    setState(() {
                      _currentStep = 0;
                      _titleController.clear();
                      _descController.clear();
                      _budgetController.clear();
                      _locationController.clear();
                      _imagesWithCaptions.clear();
                      _deadline = null;
                      _deadlineTime = null;
                      _isRemote = true;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit task: $e')),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _titleFocus = FocusNode(); // 👈 Initialize here
    _descFocus = FocusNode(); // 👈 Initialize here
    _voiceService = VoiceService();
  }

  @override
  void dispose() {
    
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  Widget _buildPreview() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          "📌 Title: ${_titleController.text}",
          style: TextStyle(fontSize: 16),
        ),
        Text("📂 Category: $_category"),
        Text("📝 Description:\n${_descController.text}"),
        SizedBox(height: 12),
        Text("💰 Budget: \$${_budgetController.text}"),
        if (_deadline != null)
          Text(
            "⏳ Deadline: ${_formatter.format(_deadline!)} ${_deadlineTime?.format(context) ?? 'No deadline'}",
          ),
        Text(
          "📍 Location: ${_isRemote ? 'Remote' : 'On Location ($_selectedState)'}",
        ),
        if (!_isRemote) Text("🏙️ City/Suburb: ${_locationController.text}"),
        SizedBox(height: 20),
        Text("🖼️ Images:", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ..._imagesWithCaptions.map(
          (img) => ListTile(
            leading: Image.file(
              img['file'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            // title: Text(img['caption'] ?? ''),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          icon: Icon(Icons.send),
          label: Text('Confirm & Submit'),
          onPressed: _submitTask,
          // onPressed: () {
          //   print('Task Submit: ${_titleController.text} ${_category} ${_descController.text} ${_budgetController.text} ${_formatter.format(_deadline!)} ${_isRemote ? 'Remote' : 'On Location ($_selectedState)'} ${_locationController.text}');
          // },
        ),
      ],
    );
  }

Widget _buildStepContent(int step) {
  switch (step) {
    case 0:
      return Form(
        key: _formKeys[0],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Title
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
                          _voiceService.stopListening(() {
                            setState(() {});
                          });
                        } else {
                          _titleFocus.unfocus();
                          _voiceService.startListening(
                            onResult: (newText) {
                              setState(() {
                                _titleController.text += ' $newText';
                              });
                            },
                            onListeningStarted: () {
                              setState(() {});
                            },
                            onListeningStopped: () {
                              setState(() {});
                            },
                          );
                        }
                      },
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),

                SizedBox(height: 12),

                // Category
                DropdownButtonFormField(
                  value: _category,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),

                SizedBox(height: 12),

                // Description
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
                          _voiceService.stopListening(() {
                            setState(() {});
                          });
                        } else {
                          _descFocus.unfocus();
                          _voiceService.startListening(
                            onResult: (newText) {
                              setState(() {
                                _descController.text += ' $newText';
                              });
                            },
                            onListeningStarted: () {
                              setState(() {});
                            },
                            onListeningStopped: () {
                              setState(() {});
                            },
                          );
                        }
                      },
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),

                SizedBox(height: 12),

                // Budget
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Budget (AUD)'),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),

                SizedBox(height: 12),

                // Deadline
                ListTile(
                  title: Text(
                    _deadline != null
                        ? '${_formatter.format(_deadline!)} ${_deadlineTime?.format(context) ?? ''}'
                        : 'Select Deadline',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _pickDeadline,
                ),

                SizedBox(height: 12),

                // Remote toggle
                SwitchListTile(
                  title: Text('Remote Task'),
                  value: _isRemote,
                  onChanged: (val) => setState(() => _isRemote = val),
                ),

                if (!_isRemote) ...[
                  // Location: State, City, Suburb
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    hint: Text('Select State'),
                    decoration: InputDecoration(labelText: 'State'),
                    items: _locationData.keys
                        .map((state) => DropdownMenuItem(
                              value: state,
                              child: Text(state),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedState = val;
                        _selectedCity = null;
                        _selectedSuburb = null;
                      });
                    },
                  ),

                  SizedBox(height: 12),

                  if (_selectedState != null)
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      hint: Text('Select City'),
                      decoration: InputDecoration(labelText: 'City'),
                      items: _locationData[_selectedState!]!.keys
                          .map((city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCity = val;
                          _selectedSuburb = null;
                        });
                      },
                    ),

                  SizedBox(height: 12),

                  if (_selectedCity != null)
                    DropdownButtonFormField<String>(
                      value: _selectedSuburb,
                      hint: Text('Select Suburb'),
                      decoration: InputDecoration(labelText: 'Suburb'),
                      items: _locationData[_selectedState!]![_selectedCity!]!
                          .map((suburb) => DropdownMenuItem(
                                value: suburb,
                                child: Text(suburb),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedSuburb = val),
                    ),
                ],
              ],
            ),
          ),
        ),
      );

    case 1:
      // Now case 1 becomes the "Upload Images" step (what was case 2 before)
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Upload Images'),
              onPressed: _pickImages,
            ),
            SizedBox(height: 10),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _imagesWithCaptions.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _imagesWithCaptions.removeAt(oldIndex);
                    _imagesWithCaptions.insert(newIndex, item);
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
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(
                          () => _imagesWithCaptions.removeAt(index)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );

    case 2:
      // Preview Step
      return _buildPreview();

    default:
      return SizedBox();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text('Post Task')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
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
                if (_currentStep < 3)
                  ElevatedButton(
                    onPressed: () {
                      final valid =
                          _formKeys[_currentStep].currentState?.validate() ??
                          true;
                      if (valid) setState(() => _currentStep++);
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
